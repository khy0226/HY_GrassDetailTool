using System.Collections.Generic;

using UnityEngine;

using UnityEngine.Rendering;

using Unity.Collections;



#if UNITY_EDITOR

using UnityEditor;

#endif



#if UNITY_EDITOR

[ExecuteAlways]

#endif

public class HY_GrassDetailRenderer : MonoBehaviour

{

    public GrassDataList grassDataList;

    private Dictionary<(GameObject prefab, string zoneName), Matrix4x4[]> instanceMatricesMap = new();

    private readonly List<List<Matrix4x4>> pooledLodMatrices = new();



    private Dictionary<GameObject, Material> materialMap = new Dictionary<GameObject, Material>();



    private bool hasGrassData = false;

    private bool isDataDirty = true;



    [SerializeField] public ComputeShader GrassCompute;



    private ComputeBuffer frustumBuffer;



    private const int GrassInputStride = sizeof(float) * 10;

    private Dictionary<GameObject, List<GrassInstanceInput>> drawDataCache = new();

    private Dictionary<GameObject, ComputeBuffer> inputBufferMap = new();

    Dictionary<(GameObject, int), ComputeBuffer> actualMatrixLODBufferMap = new Dictionary<(GameObject, int), ComputeBuffer>();

    Dictionary<(GameObject, int), ComputeBuffer> computeArgsLODBufferMap = new Dictionary<(GameObject, int), ComputeBuffer>();

    Dictionary<(GameObject, int, int, Material), ComputeBuffer> indirectArgsSubMeshBufferMap = new Dictionary<(GameObject, int, int, Material), ComputeBuffer>(); // Added Material to key for safety if needed, or just subMeshIndex if material doesn't alter args structure

    Dictionary<(GameObject, int, int, Material), MaterialPropertyBlock> mpbMap = new Dictionary<(GameObject, int, int, Material), MaterialPropertyBlock>();



    private void OnEnable()

    {

        LoadLODsForAllPrefabs();

        UpdateGrassInstances();

        hasGrassData = grassDataList != null && grassDataList.grassTypes.Count > 0;

        isDataDirty = true;



#if UNITY_EDITOR

        SceneView.duringSceneGui += OnSceneGUI;

#endif

    }



    private void OnDisable()

    {

#if UNITY_EDITOR

        SceneView.duringSceneGui -= OnSceneGUI;

#endif



        ReleaseBuffers();

    }



    private void LateUpdate()

    {

        if (!Application.isPlaying || !hasGrassData) return;



        if (isDataDirty)

        {

            UpdateGrassInstances();

            isDataDirty = false;

        }

        RenderGrass();

    }



#if UNITY_EDITOR

    private void OnDrawGizmos()

    {

        if (!Application.isPlaying && hasGrassData)

        {

            if (Event.current == null || Event.current.type != EventType.Repaint)

                return;



            RenderGrass();

        }

    }



    private void OnSceneGUI(SceneView sceneView)

    {

        if (!Application.isPlaying && hasGrassData)

        {

            RenderGrass(); // Handles.BeginGUI() 제거

        }

    }

    private void OnValidate()

    {

        if (!Application.isPlaying && grassDataList != null)

        {

            SetGrassData(grassDataList);

        }

        ReleaseBuffers();

    }

#endif



    void OnDestroy()

    {

        ReleaseBuffers();

    }



    public void ForceEnableRender()

    {

        hasGrassData = grassDataList != null && grassDataList.grassTypes.Count > 0;

        isDataDirty = true;

    }



    private void UpdateGrassInstances()

    {

        instanceMatricesMap.Clear();



        if (grassDataList == null || grassDataList.zones == null) return;



        foreach (var zone in grassDataList.zones)

        {

            foreach (var group in zone.instanceGroups)

            {

                var typeData = grassDataList.grassTypes.Find(t => t.prefab == group.prefab);

                if (typeData == null || typeData.lodLevels == null || typeData.lodLevels.Count == 0)

                    continue;



                int instanceCount = group.instances.Count;

                if (instanceCount == 0) continue;



                Matrix4x4[] instanceMatrices = new Matrix4x4[instanceCount];

                for (int i = 0; i < instanceCount; i++)

                {

                    GrassData grass = group.instances[i];

                    instanceMatrices[i] = Matrix4x4.TRS(grass.position, grass.rotation, grass.scale);

                }



                instanceMatricesMap[(group.prefab, zone.zoneName)] = instanceMatrices;

            }

        }



        isDataDirty = false;

    }



    public void SetGrassData(GrassDataList data)

    {

        if (data == null)

        {

            Debug.LogError("GrassDataList가 없습니다!");

            return;

        }



        grassDataList = data;

        hasGrassData = grassDataList.grassTypes.Count > 0;



        LoadLODsForAllPrefabs();

        isDataDirty = true;



        // 즉시 적용

        UpdateGrassInstances();

        RenderGrass();

    }



    public void ApplyInstanceUpdate()

    {

        if (grassDataList == null) return;



        LoadLODsForAllPrefabs(); // LOD 및 머티리얼 정보 로드 (프리팹 관련 데이터 갱신)

        UpdateGrassInstances(); // 잔디 오브젝트들의 위치, 회전, 크기 데이터를 갱신 (인스턴스 행렬 업데이트)

        RenderGrass(); // GPU 인스턴싱을 사용하여 잔디를 실제로 렌더링 (화면에 표시)

    }



    private void LoadLODsForAllPrefabs()

    {

        if (grassDataList == null || grassDataList.grassTypes == null) return;



        foreach (var grassType in grassDataList.grassTypes)

        {

            if (grassType.prefab == null) continue;



            // LOD 수집

            //grassType.LoadLODFromPrefab();



            // 기본 fallback용 materialMap 등록 (LOD0 첫 번째)

            if (grassType.lodLevels.Count > 0 && grassType.lodLevels[0].renderers.Count > 0)

            {

                materialMap[grassType.prefab] = grassType.lodLevels[0].renderers[0].material;

            }

        }

    }



    private int GetLODIndex(GrassTypeData data, float normDistance)

    {

        float bias = grassDataList.useGlobalLOD ? QualitySettings.lodBias : 1.0f;

        float adjusted = Mathf.Clamp01(normDistance / bias);



        for (int i = 0; i < data.lodLevels.Count - 1; i++)

        {

            if (adjusted < data.lodLevels[i].transitionDistance)

                return i;

        }



        return data.lodLevels.Count - 1;

    }



    float GetLODDistance(int lodIndex, GrassTypeData grassType, float maxCull)

    {

        float bias = grassDataList.useGlobalLOD ? QualitySettings.lodBias : 1.0f;



        if (lodIndex >= grassType.lodLevels.Count)

            return maxCull + 1f;



        float t = grassType.lodLevels[lodIndex].transitionDistance;



        if (Mathf.Approximately(t, 1f))

            return t * maxCull;



        return t * maxCull * bias;

    }



    private Camera GetRenderCamera()

    {

        if (Application.isPlaying)

        {

            return Camera.main; // 플레이 중이면 메인 카메라 사용

        }

        else

        {

#if UNITY_EDITOR

            if (SceneView.lastActiveSceneView != null)

            {

                return SceneView.lastActiveSceneView.camera; // 씬 뷰에서 가장 최근 카메라 사용

            }

#endif

            return null; // 카메라가 없으면 렌더링 중단

        }

    }



    private void EnsurePooledLodListCapacity(int requiredCount)

    {

        if (pooledLodMatrices.Count < requiredCount)

        {

            for (int i = pooledLodMatrices.Count; i < requiredCount; i++)

                pooledLodMatrices.Add(new List<Matrix4x4>());

        }

    }





    public void RenderGrass()

    {

        GrassDataList data = grassDataList;



        if (data.renderMode == GrassDataList.RenderMode.DrawMeshInstanced)

        {

            RenderGrassDrawMeshInstanced();

        }

        else

        {

            RenderGrassDrawMeshInstancedIndirect();

        }

    }



    private void RenderGrassDrawMeshInstanced()

    {

        Camera cam = GetRenderCamera();

        if (!hasGrassData || cam == null) return;



        Vector3 camPos = cam.transform.position;

        float cullDistSqr = grassDataList.maxCullDistance * grassDataList.maxCullDistance;

        Plane[] frustumPlanes = GeometryUtility.CalculateFrustumPlanes(cam);

        float frustumPadding = 0.5f;

        for (int i = 0; i < frustumPlanes.Length; i++)

        {

            frustumPlanes[i].distance += frustumPadding;

        }



        foreach (var zone in grassDataList.zones)

        {

            if (zone.zoneName == "_DefaultZone")

            {

                continue;

            }



            // Zone 중심 계산 (Y는 무시 - XZ 기준)

            Vector3 zoneWorldCenter = new Vector3(zone.zoneCenter.x, camPos.y, zone.zoneCenter.y);



            // zoneSize가 셀 한변의 길이라면, 실제 반지름은 절반

            float zoneRadius = zone.zoneSize * 0.5f;

            float combinedRadius = zoneRadius + grassDataList.maxCullDistance;



            // 거리 체크 (XZ 기준)

            Vector2 camXZ = new Vector2(camPos.x, camPos.z);

            Vector2 zoneXZ = zone.zoneCenter;

            if ((camXZ - zoneXZ).sqrMagnitude > combinedRadius * combinedRadius)

                continue;



            foreach (var group in zone.instanceGroups)

            {

                var typeData = grassDataList.grassTypes.Find(t => t.prefab == group.prefab);

                if (typeData == null || typeData.lodLevels == null || typeData.lodLevels.Count == 0) continue;

                if (!instanceMatricesMap.TryGetValue((group.prefab, zone.zoneName), out Matrix4x4[] matrices)) continue;

                if (matrices == null || matrices.Length == 0) continue;



                int lodCount = typeData.lodLevels.Count;

                bool shadow = typeData.hasShadow;



                // 기존 풀에서 재사용 또는 생성

                EnsurePooledLodListCapacity(lodCount);



                for (int i = 0; i < lodCount; i++)

                    pooledLodMatrices[i].Clear();



                // 인스턴스별 거리 및 LOD 계산

                for (int i = 0; i < matrices.Length; i++)

                {

                    Vector3 pos = matrices[i].GetColumn(3);



                    Bounds b = new Bounds(pos, new Vector3(1, 1, 1));

                    if (!GeometryUtility.TestPlanesAABB(frustumPlanes, b))

                        continue;



                    float distSqr = (camPos - pos).sqrMagnitude;

                    if (distSqr > cullDistSqr) continue;



                    float normDist = Mathf.Sqrt(distSqr) / grassDataList.maxCullDistance;

                    int lodIndex = GetLODIndex(typeData, normDist);



                    if (lodIndex >= 0 && lodIndex < lodCount)

                        pooledLodMatrices[lodIndex].Add(matrices[i]);

                }



                // LOD별 인스턴스 렌더링

                for (int lodIdx = 0; lodIdx < lodCount; lodIdx++)

                {

                    var lodList = pooledLodMatrices[lodIdx];

                    if (lodList.Count == 0) continue;



                    var renderers = typeData.lodLevels[lodIdx].renderers;



                    foreach (var elem in renderers)

                    {

                        if (elem.mesh == null || elem.material == null) continue;



                        Graphics.DrawMeshInstanced(

                          elem.mesh,

                          elem.subMeshIndex,

                          elem.material,

                          lodList,

                          null,

                          shadow ? ShadowCastingMode.On : ShadowCastingMode.Off,

                          true,

                          gameObject.layer

                        );

                    }

                }

            }

        }

    }



    struct GrassInstanceInput

    {

        public Vector3 position;

        public Quaternion rotation;

        public Vector3 scale;

    }



    private void RenderGrassDrawMeshInstancedIndirect()

    {

        Camera cam = GetRenderCamera();

        if (!hasGrassData || cam == null) return;



        Vector3 camPos = cam.transform.position;



        Vector3 boundsSize = new Vector3

          (

          grassDataList.mapSize.x * 2,

          5000,

          grassDataList.mapSize.y * 2

          );

        Bounds bounds = new Bounds(new Vector3(0, 0, 0), boundsSize);



        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(cam);

        Vector4[] gpuPlanes = new Vector4[6];

        for (int i = 0; i < 6; i++)

        {

            var p = planes[i];

            gpuPlanes[i] = new Vector4(p.normal.x, p.normal.y, p.normal.z, p.distance);

        }



        if (frustumBuffer == null || frustumBuffer.count != 6)

        {

            frustumBuffer?.Release();

            frustumBuffer = new ComputeBuffer(6, sizeof(float) * 4);

        }



        int kernel = GrassCompute.FindKernel("CSMain");



        frustumBuffer.SetData(gpuPlanes);

        GrassCompute.SetBuffer(kernel, "_FrustumPlanes", frustumBuffer);



        foreach (var grassType in grassDataList.grassTypes)

        {

            GameObject prefab = grassType.prefab;

            if (prefab == null) continue;



            if (!drawDataCache.TryGetValue(prefab, out var instanceList))

            {

                instanceList = new List<GrassInstanceInput>();



                foreach (var zone in grassDataList.zones)

                {

                    foreach (var group in zone.instanceGroups)

                    {

                        if (group.prefab != prefab) continue;



                        foreach (var inst in group.instances)

                        {

                            instanceList.Add(new GrassInstanceInput
                            {

                                position = inst.position,

                                rotation = inst.rotation,

                                scale = inst.scale

                            });

                        }

                    }

                }



                drawDataCache[prefab] = instanceList;

            }



            int instanceCount = instanceList.Count;

            if (instanceCount == 0) continue;



            if (!inputBufferMap.TryGetValue(prefab, out var inputBuffer) || inputBuffer.count != instanceCount)

            {

                inputBuffer?.Release();

                inputBuffer = new ComputeBuffer(instanceCount, GrassInputStride);

                inputBufferMap[prefab] = inputBuffer;

                inputBuffer.SetData(instanceList);

            }



            for (int lod = 0; lod < 3; lod++)

            {

                var actualMatrixKey = (prefab, lod);

                if (!actualMatrixLODBufferMap.TryGetValue(actualMatrixKey, out var currentActualMatrixBuffer) || currentActualMatrixBuffer.count != instanceCount)

                {

                    currentActualMatrixBuffer?.Release();

                    currentActualMatrixBuffer = new ComputeBuffer(instanceCount, 40, ComputeBufferType.Append);

                    actualMatrixLODBufferMap[actualMatrixKey] = currentActualMatrixBuffer;

                }

                currentActualMatrixBuffer.SetCounterValue(0); // 



                var computeArgsKey = (prefab, lod);

                if (!computeArgsLODBufferMap.TryGetValue(computeArgsKey, out var currentComputeArgsBuffer))

                {

                    currentComputeArgsBuffer?.Release();

                    currentComputeArgsBuffer = new ComputeBuffer(1, sizeof(uint) * 5, ComputeBufferType.IndirectArguments);

                    computeArgsLODBufferMap[computeArgsKey] = currentComputeArgsBuffer;

                }

                currentComputeArgsBuffer.SetData(new uint[5] { 0, 0, 0, 0, 0 });



                if (lod < grassType.lodLevels.Count)

                {

                    var lodLevelData = grassType.lodLevels[lod];

                    foreach (var rend in lodLevelData.renderers)

                    {

                        if (rend.mesh == null) continue;

                        var indirectArgsKey = (prefab, lod, rend.subMeshIndex, rend.material);

                        if (!indirectArgsSubMeshBufferMap.TryGetValue(indirectArgsKey, out var currentIndirectArgsBuffer))

                        {

                            currentIndirectArgsBuffer?.Release();

                            currentIndirectArgsBuffer = new ComputeBuffer(1, sizeof(uint) * 5, ComputeBufferType.IndirectArguments);

                            indirectArgsSubMeshBufferMap[indirectArgsKey] = currentIndirectArgsBuffer;

                        }



                        uint indexCountSubmesh = (uint)rend.mesh.GetIndexCount(rend.subMeshIndex);

                        uint indexStartSubmesh = (uint)rend.mesh.GetIndexStart(rend.subMeshIndex);

                        uint baseVertexSubmesh = (uint)rend.mesh.GetBaseVertex(rend.subMeshIndex);

                        currentIndirectArgsBuffer.SetData(new uint[5] { indexCountSubmesh, 0, indexStartSubmesh, baseVertexSubmesh, 0 });

                    }

                }

            }



            float lod0Distance = GetLODDistance(0, grassType, grassDataList.maxCullDistance);

            float lod1Distance = GetLODDistance(1, grassType, grassDataList.maxCullDistance);



            GrassCompute.SetFloat("_LOD0Distance", lod0Distance);

            GrassCompute.SetFloat("_LOD1Distance", lod1Distance);



            GrassCompute.SetBuffer(kernel, "_InputData", inputBuffer);

            GrassCompute.SetVector("_CameraPos", camPos);

            GrassCompute.SetFloat("_MaxDistance", grassDataList.maxCullDistance);



            GrassCompute.SetInt("_InstanceCount", instanceCount);



            GrassCompute.SetBuffer(kernel, "_DrawDatasLOD0", actualMatrixLODBufferMap[(prefab, 0)]);

            GrassCompute.SetBuffer(kernel, "_DrawDatasLOD1", actualMatrixLODBufferMap[(prefab, 1)]);

            GrassCompute.SetBuffer(kernel, "_DrawDatasLOD2", actualMatrixLODBufferMap[(prefab, 2)]);



            GrassCompute.SetBuffer(kernel, "_ArgsBufferLOD0", computeArgsLODBufferMap[(prefab, 0)]);

            GrassCompute.SetBuffer(kernel, "_ArgsBufferLOD1", computeArgsLODBufferMap[(prefab, 1)]);

            GrassCompute.SetBuffer(kernel, "_ArgsBufferLOD2", computeArgsLODBufferMap[(prefab, 2)]);





            if (instanceCount > 0)

            {

                GrassCompute.Dispatch(kernel, Mathf.CeilToInt(instanceCount / 64f), 1, 1);

            }



            for (int lodIndex = 0; lodIndex < grassType.lodLevels.Count; lodIndex++)

            {

                var lodLevel = grassType.lodLevels[lodIndex];

                if (lodLevel.renderers == null || lodLevel.renderers.Count == 0) continue;



                var currentActualMatrixLODBuffer = actualMatrixLODBufferMap[(prefab, lodIndex)];



                foreach (var rend in lodLevel.renderers)

                {

                    var mesh = rend.mesh;

                    var mat = rend.material;

                    int subMesh = rend.subMeshIndex;



                    if (mesh == null || mat == null) continue;



                    var indirectArgsKey = (prefab, lodIndex, subMesh, mat);

                    var indirectArgsBufferForSubmesh = indirectArgsSubMeshBufferMap[indirectArgsKey];



                    ComputeBuffer.CopyCount(currentActualMatrixLODBuffer, indirectArgsBufferForSubmesh, sizeof(uint));



                    var mpbKey = (prefab, lodIndex, subMesh, mat);

                    if (!mpbMap.TryGetValue(mpbKey, out var mpb))

                    {

                        mpb = new MaterialPropertyBlock();

                        mpbMap[mpbKey] = mpb;

                    }

                    else

                    {

                        mpb.Clear();

                    }



                    mpb.SetBuffer("_Matrices", currentActualMatrixLODBuffer);

                    mat.enableInstancing = true;



                    Graphics.DrawMeshInstancedIndirect(

                      mesh,

                      subMesh,

                      mat,

                      bounds,

                      indirectArgsBufferForSubmesh,

                      0,

                      mpb,

                      grassType.hasShadow ? ShadowCastingMode.On : ShadowCastingMode.Off,

                      true,

                      gameObject.layer

                    );

                }

            }

        }

    }



    private void ReleaseBuffers()

    {

        if (actualMatrixLODBufferMap != null)

        {

            foreach (var buffer in actualMatrixLODBufferMap.Values)

                buffer?.Release();

            actualMatrixLODBufferMap.Clear();

        }



        if (computeArgsLODBufferMap != null)

        {

            foreach (var buffer in computeArgsLODBufferMap.Values)

                buffer?.Release();

            computeArgsLODBufferMap.Clear();

        }



        if (indirectArgsSubMeshBufferMap != null)

        {

            foreach (var buffer in indirectArgsSubMeshBufferMap.Values)

                buffer?.Release();

            indirectArgsSubMeshBufferMap.Clear();

        }



        if (inputBufferMap != null)

        {

            foreach (var buffer in inputBufferMap.Values)

                buffer?.Release();

            inputBufferMap.Clear();

        }



        if (frustumBuffer != null)

        {

            frustumBuffer.Release();

            frustumBuffer = null;

        }



        if (drawDataCache != null)

        {

            drawDataCache.Clear();

        }



        if (mpbMap != null)

        {

            mpbMap.Clear();

        }

    }



}
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text.RegularExpressions;

[CustomEditor(typeof(GrassDataList))]
public class GrassDataListEditor : Editor
{
    private Dictionary<int, bool> prefabFoldout = new Dictionary<int, bool>();
    private Dictionary<int, bool> zoneFoldout = new Dictionary<int, bool>();
    private Dictionary<(int prefabId, int lod), bool> meshMaterials = new();

    private GameObject pendingNewPrefab = null;
    private GrassTypeData pendingTargetTypeData = null;

    public override void OnInspectorGUI()
    {
        GrassDataList data = (GrassDataList)target;

        // 지도 설정
        GUILayout.Label("지도 및 존 설정", EditorStyles.boldLabel);
        data.mapSize = EditorGUILayout.Vector2Field("전체 맵 크기", data.mapSize);
        data.divisionCountX = EditorGUILayout.IntField("X 분할 수", data.divisionCountX);
        data.divisionCountY = EditorGUILayout.IntField("Y 분할 수", data.divisionCountY);

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("존 자동 분할")) SplitZones(data);
        if (GUILayout.Button("존 모두 통합")) MergeZones(data);
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(10);
        GUILayout.Label("공통 잔디 설정", EditorStyles.boldLabel);
        data.maxCullDistance = EditorGUILayout.FloatField("Max Cull Distance", data.maxCullDistance);
        data.useGlobalLOD = EditorGUILayout.Toggle("Use Global LOD", data.useGlobalLOD);

        GUILayout.Space(10);
        GUILayout.Label("렌더링 방식 설정", EditorStyles.boldLabel);

        EditorGUI.BeginChangeCheck();
        data.renderMode = (GrassDataList.RenderMode)EditorGUILayout.EnumPopup("렌더링 모드", data.renderMode);
        if (EditorGUI.EndChangeCheck())
        {
            switch (data.renderMode)
            {
                case GrassDataList.RenderMode.DrawMeshInstancedIndirect:
                    ApplyGPUModeMaterials(data);
                    break;

                case GrassDataList.RenderMode.DrawMeshInstanced:
                    RestoreOriginalMaterials(data);
                    break;
            }
        }



        GUILayout.Space(15);
        GUILayout.Label("프리팹 설정", EditorStyles.boldLabel);

        for (int i = 0; i < data.grassTypes.Count; i++)
        {
            var typeData = data.grassTypes[i];

            if (!prefabFoldout.ContainsKey(i))
                prefabFoldout[i] = true;

            prefabFoldout[i] = EditorGUILayout.Foldout(prefabFoldout[i], $"프리팹 {i}: {typeData.prefab?.name ?? "Unnamed"}", true);
            if (!prefabFoldout[i]) continue;

            EditorGUI.indentLevel++;

            EditorGUILayout.BeginHorizontal();
            var originalPrefab = typeData.prefab;
            var newPrefab = (GameObject)EditorGUILayout.ObjectField("Prefab", typeData.prefab, typeof(GameObject), false, GUILayout.Height(26));

            if (data.renderMode == GrassDataList.RenderMode.DrawMeshInstanced)
            {
                if (GUILayout.Button(EditorGUIUtility.IconContent("Refresh"), GUILayout.Width(26), GUILayout.Height(26)))
                {
                    typeData.LoadLODFromPrefab(true);
                }                
            }

            if (GUILayout.Button("X", GUILayout.Width(26), GUILayout.Height(26)))
            {
                GrassDataTypePrefabRemove(data, typeData);
            }

            EditorGUILayout.EndHorizontal();

            if (originalPrefab != newPrefab)
            {
                pendingNewPrefab = newPrefab;
                pendingTargetTypeData = typeData;
                typeData.prefab = originalPrefab;
            }

            if (data.renderMode == GrassDataList.RenderMode.DrawMeshInstancedIndirect)
            {
                ShowShaderGraphWarnings(typeData);
            }

            PrefabChange(data, typeData);

            EditorGUI.BeginChangeCheck();

            typeData.hasShadow = EditorGUILayout.Toggle("그림자 사용", typeData.hasShadow);

            GUILayout.Space(5);

            // 프리팹 루프 내부에서
            if (typeData.lodLevels != null && typeData.lodLevels.Count > 0)
            {
                for (int lod = 0; lod < typeData.lodLevels.Count; lod++)
                {
                    var lodLevel = typeData.lodLevels[lod];

                    GUILayout.BeginVertical("box");
                    EditorGUILayout.LabelField($"LOD {lod}", EditorStyles.boldLabel);

                    // 마지막 LOD는 슬라이더 제거하고 안내 문구만
                    if (lod < typeData.lodLevels.Count - 1)
                    {
                        lodLevel.transitionDistance = EditorGUILayout.Slider(
                            "Transition Distance",
                            lodLevel.transitionDistance,
                            0.01f,
                            1.0f
                        );
                    }
                    else
                    {
                        EditorGUILayout.LabelField("Transition Distance", "항상 유지 (최종 LOD)");
                    }

                    EditorGUI.indentLevel++;

                    int prefabId = typeData.prefab != null ? typeData.prefab.GetInstanceID() : 0;
                    var key = (prefabId, lod);

                    if (!meshMaterials.ContainsKey(key))
                        meshMaterials[key] = false;

                    meshMaterials[key] = EditorGUILayout.Foldout(meshMaterials[key], $"Mesh Materials", false);

                    if (meshMaterials[key])
                    {
                        if (lodLevel.renderers != null && lodLevel.renderers.Count > 0)
                        {
                            for (int r = 0; r < lodLevel.renderers.Count; r++)
                            {
                                var rend = lodLevel.renderers[r];

                                rend.mesh = (Mesh)EditorGUILayout.ObjectField($"Mesh {r}", rend.mesh, typeof(Mesh), false);
                                rend.material = (Material)EditorGUILayout.ObjectField($"Material {r}", rend.material, typeof(Material), false);

                                if (rend.material != null && !rend.material.enableInstancing)
                                {
                                    EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);

                                    GUILayout.Label(EditorGUIUtility.IconContent("console.erroricon"), GUILayout.Width(40), GUILayout.Height(40));

                                    EditorGUILayout.LabelField(
                                        "이 매터리얼은 GPU 인스턴싱이 비활성화 되어 있습니다.",
                                        EditorStyles.miniLabel,
                                        GUILayout.ExpandWidth(true), GUILayout.Height(40)
                                    );

                                    GUILayout.Space(5);
                                    if (GUILayout.Button("활성화", GUILayout.Width(80), GUILayout.Height(30)))
                                    {
                                        rend.material.enableInstancing = true;
                                        EditorUtility.SetDirty(rend.material);
                                    }

                                    EditorGUILayout.EndHorizontal();
                                }
                            }
                        }
                        else
                        {
                            EditorGUILayout.HelpBox("Renderer가 없습니다", MessageType.Warning);
                        }
                    }
                    EditorGUI.indentLevel--;

                    GUILayout.EndVertical();
                }
            }

            else
            {
                EditorGUILayout.HelpBox("LOD 레벨 정보가 없습니다. 프리팹을 다시 등록하세요.", MessageType.Warning);
            }
            EditorGUI.indentLevel--;
            GUILayout.Space(10);
        }

        // 등록된 존 목록
        GUILayout.Space(15);
        GUILayout.Label($"등록된 존 ({data.zones.Count})", EditorStyles.boldLabel);
        for (int i = 0; i < data.zones.Count; i++)
        {
            var zone = data.zones[i];

            if (!zoneFoldout.ContainsKey(i))
                zoneFoldout[i] = true;

            zoneFoldout[i] = EditorGUILayout.Foldout(zoneFoldout[i], $"Zone {i} - {zone.zoneName} ({zone.instanceGroups.Count} 프리팹)", true);
            if (!zoneFoldout[i]) continue;

            EditorGUI.indentLevel++;
            foreach (var group in zone.instanceGroups)
            {
                string name = group.prefab != null ? group.prefab.name : "미지정 프리팹";
                EditorGUILayout.LabelField($"{name} - {group.instances.Count}개");
            }
            EditorGUI.indentLevel--;
        }

        if (GUI.changed)
            EditorUtility.SetDirty(target);
    }

    private void ForceRenderUpdateInScene()
    {
        var renderer = GameObject.FindObjectOfType<HY_GrassDetailRenderer>();
        if (renderer != null)
        {
            renderer.ForceEnableRender();
            renderer.ApplyInstanceUpdate();
        }
    }

    // 존 자동 분할
    private void SplitZones(GrassDataList data)
    {
        try
        {
            EditorUtility.DisplayProgressBar("Zone 자동 분할", "기존 데이터를 병합 중...", 0f);
            MoveAllToDefaultZone(data); // 기존 → Default

            data.zones.RemoveAll(z => z.zoneName != "_DefaultZone");

            float cellWidth = data.mapSize.x / data.divisionCountX;
            float cellHeight = data.mapSize.y / data.divisionCountY;

            int totalZones = data.divisionCountX * data.divisionCountY;
            int current = 0;

            for (int y = 0; y < data.divisionCountY; y++)
            {
                for (int x = 0; x < data.divisionCountX; x++)
                {
                    current++;
                    float progress = (float)current / totalZones;
                    EditorUtility.DisplayProgressBar("Zone 자동 분할", $"Zone {current}/{totalZones} 생성 중...", progress);

                    GrassZone newZone = new GrassZone {
                        zoneName = $"Zone_{x}_{y}",
                        zoneSize = Mathf.Max(cellWidth, cellHeight),
                        zoneCenter = new Vector2((x + 0.5f) * cellWidth, (y + 0.5f) * cellHeight),
                        instanceGroups = new List<GrassZoneInstanceGroup>()
                    };
                    data.zones.Add(newZone);
                }
            }

            Debug.Log($"{data.zones.Count}개의 Zone 생성 완료!");

            EditorUtility.DisplayProgressBar("Zone 자동 분할", "DefaultZone 데이터를 분배 중...", 0.99f);
            AutoDistributeDefaultZone(data); // 분배

            ForceRenderUpdateInScene();
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
    }


    // 존 통합
    private void MergeZones(GrassDataList data)
    {
        try
        {
            EditorUtility.DisplayProgressBar("Zone 병합", "DefaultZone으로 이동 중...", 0f);
            MoveAllToDefaultZone(data);
            data.zones.RemoveAll(z => z.zoneName != "_DefaultZone");

            GrassZone mergedZone = new GrassZone {
                zoneName = "Zone_0_0",
                zoneCenter = data.mapSize * 0.5f,
                zoneSize = Mathf.Max(data.mapSize.x, data.mapSize.y),
                instanceGroups = new List<GrassZoneInstanceGroup>()
            };

            data.zones.Add(mergedZone);
            Debug.Log("모든 Zone을 하나로 통합했습니다.");

            var defaultZone = data.zones.FirstOrDefault(z => z.zoneName == "_DefaultZone");
            if (defaultZone == null) return;

            var allInstances = defaultZone.instanceGroups
                .SelectMany(g => g.instances.Select(inst => (g.prefab, inst)))
                .ToList();

            defaultZone.instanceGroups.Clear();

            int total = allInstances.Count;
            for (int i = 0; i < total; i++)
            {
                float progress = (float)i / total;
                EditorUtility.DisplayProgressBar("Zone 병합", $"인스턴스 병합 중... {i}/{total}", progress);

                var (prefab, grass) = allInstances[i];
                data.AddToZoneInstanceGroup("Zone_0_0", prefab, grass);
            }

            ForceRenderUpdateInScene();
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
    }


    public static void MoveAllToDefaultZone(GrassDataList data)
    {
        GrassZone defaultZone = data.zones.FirstOrDefault(z => z.zoneName == "_DefaultZone");
        if (defaultZone == null)
        {
            defaultZone = new GrassZone {
                zoneName = "_DefaultZone",
                zoneCenter = data.mapSize * 0.5f,
                zoneSize = Mathf.Max(data.mapSize.x, data.mapSize.y),
                instanceGroups = new List<GrassZoneInstanceGroup>()
            };
            data.zones.Add(defaultZone);
        }

        foreach (var zone in data.zones.ToArray())
        {
            if (zone.zoneName == "_DefaultZone") continue;

            foreach (var group in zone.instanceGroups)
            {
                foreach (var grass in group.instances)
                {
                    data.AddToZoneInstanceGroup("_DefaultZone", group.prefab, grass);
                }
            }

            zone.instanceGroups.Clear();
        }

        Debug.Log("모든 잔디 데이터를 _DefaultZone 으로 이동 완료.");
    }

    public static void AutoDistributeDefaultZone(GrassDataList data)
    {
        var defaultZone = data.zones.FirstOrDefault(z => z.zoneName == "_DefaultZone");
        if (defaultZone == null) return;

        // Zone_0_0만 남아있는 상태인지 확인
        bool isMergedOnly = data.zones.Count == 2 && data.zones.Any(z => z.zoneName == "Zone_0_0");

        List<(GameObject prefab, GrassData grass)> allInstances = new();

        foreach (var group in defaultZone.instanceGroups)
        {
            foreach (var grass in group.instances)
            {
                allInstances.Add((group.prefab, grass));
            }
        }

        defaultZone.instanceGroups.Clear(); // 디폴트 존 비우기

        foreach (var (prefab, grass) in allInstances)
        {
            string zoneName = isMergedOnly
                ? "Zone_0_0"
                : CalculateZoneName(grass.position, data);

            data.AddToZoneInstanceGroup(zoneName, prefab, grass);
        }

        data.zones.RemoveAll(zone => zone.zoneName != "_DefaultZone" && (zone.instanceGroups == null || zone.instanceGroups.Count == 0));
        RecalculateZoneCenters(data);
    }

    public static void RecalculateZoneCenters(GrassDataList data)
    {
        foreach (var zone in data.zones)
        {
            if (zone.instanceGroups == null || zone.instanceGroups.Count == 0)
                continue;

            var allPositions = zone.instanceGroups
                .SelectMany(g => g.instances.Select(inst => inst.position))
                .ToList();

            if (allPositions.Count > 0)
            {
                Vector3 avg = allPositions.Aggregate(Vector3.zero, (sum, pos) => sum + pos) / allPositions.Count;
                zone.zoneCenter = new Vector2(avg.x, avg.z);
            }
        }
    }

    public static string CalculateZoneName(Vector3 position, GrassDataList data)
    {
        int x = Mathf.FloorToInt(position.x / (data.mapSize.x / data.divisionCountX));
        int y = Mathf.FloorToInt(position.z / (data.mapSize.y / data.divisionCountY));

        x = Mathf.Clamp(x, 0, data.divisionCountX - 1);
        y = Mathf.Clamp(y, 0, data.divisionCountY - 1);

        return $"Zone_{x}_{y}";
    }

    private void PrefabChange(GrassDataList data, GrassTypeData typeData)
    {
        if (pendingNewPrefab != null && pendingTargetTypeData == typeData)
        {
            EditorGUILayout.Space();
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(EditorGUIUtility.IconContent("console.warnicon"), GUILayout.Width(40));
            if (data.renderMode == GrassDataList.RenderMode.DrawMeshInstanced)
            {
                EditorGUILayout.LabelField(
                "프리팹이 변경되었습니다.\n잔디 인스턴스에 새 프리팹을 적용할까요?",
                EditorStyles.wordWrappedLabel
                );
            }
            else
            {
                EditorGUILayout.LabelField(                
                "Draw Mesh Instanced 모드로 변경하고 프리팹을 교체하세요.",
                EditorStyles.wordWrappedLabel
                );
            }

            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();

            if (data.renderMode == GrassDataList.RenderMode.DrawMeshInstanced)
            {
                if (GUILayout.Button("교체하기"))
                {
                    ApplyPrefabReplacement(data, pendingTargetTypeData, pendingNewPrefab);

                    if (data.renderMode == GrassDataList.RenderMode.DrawMeshInstancedIndirect)
                    {
                        ApplyGPUModeMaterials(data);
                    }

                    pendingNewPrefab = null;
                    pendingTargetTypeData = null;
                    GUI.FocusControl(null);
                    ForceRenderUpdateInScene();
                }
                if (GUILayout.Button("취소"))
                {
                    pendingNewPrefab = null;
                    pendingTargetTypeData = null;
                    GUI.FocusControl(null);
                }
            }
            else
            {
                if (GUILayout.Button("확인"))
                {
                    pendingNewPrefab = null;
                    pendingTargetTypeData = null;
                    GUI.FocusControl(null);
                }
            }

            EditorGUILayout.EndHorizontal();

            EditorGUILayout.EndVertical();
        }
    }

    private void ApplyPrefabReplacement(GrassDataList data, GrassTypeData oldType, GameObject newPrefab)
    {
        GameObject oldPrefab = oldType.prefab;

        oldType.prefab = newPrefab;
        oldType.LoadLODFromPrefab(false); // 새 프리팹에 맞춰 LOD 다시 로드

        foreach (var zone in data.zones)
        {
            foreach (var group in zone.instanceGroups)
            {
                if (group.prefab == oldPrefab)
                {
                    group.prefab = newPrefab;
                }
            }
        }

        EditorUtility.SetDirty(data);
        AssetDatabase.SaveAssets();

        Debug.Log($"프리팹 교체 완료: {oldPrefab.name} → {newPrefab.name}");
    }

    private void ApplyGPUModeMaterials(GrassDataList data)
    {
        // 캐시 초기화
        Dictionary<Shader, Shader> shaderCache = new();
        Dictionary<Material, Material> materialCache = new();
        Dictionary<Material, Shader> originalToShaderMap = new();
        HashSet<Material> allOriginalMaterials = new();

        // 1️⃣ Pass 1: 모든 원본 Material 수집
        foreach (var typeData in data.grassTypes)
        {
            foreach (var lod in typeData.lodLevels)
            {
                foreach (var renderer in lod.renderers)
                {
                    var originalMat = renderer.material;
                    if (originalMat == null || originalMat.name.Contains("(GPUMode)")) continue;

                    if (!allOriginalMaterials.Contains(originalMat))
                    {
                        allOriginalMaterials.Add(originalMat);
                        originalToShaderMap[originalMat] = originalMat.shader;
                    }
                }
            }
        }

        // 2️⃣ Pass 2: GPU 쉐이더 + GPU 머티리얼 생성
        foreach (var originalMat in allOriginalMaterials)
        {
            Shader originalShader = originalToShaderMap[originalMat];
            Shader gpuShader;

            if (!shaderCache.TryGetValue(originalShader, out gpuShader))
            {
                string shaderPath = AssetDatabase.GetAssetPath(originalShader);
                string folder = Path.GetDirectoryName(shaderPath);
                string baseShaderName = Path.GetFileNameWithoutExtension(shaderPath);

                bool isShaderGraph = shaderPath.EndsWith(".shadergraph") || originalShader.name.StartsWith("Shader Graphs/");
                string gpuShaderName = originalShader.name + "(GPUMode)";

                if (isShaderGraph)
                {
                    gpuShader = Shader.Find(gpuShaderName);
                    if (gpuShader == null)
                    {
                        Debug.LogWarning($"[GPUMode] Shader Graph GPU 쉐이더 '{gpuShaderName}'을 찾을 수 없습니다. 원본 쉐이더 유지");
                        gpuShader = originalShader;
                    }
                    else
                    {
                        Debug.Log($"[GPUMode] Shader Graph 쉐이더 대체: {originalShader.name} → {gpuShader.name}");
                    }

                    shaderCache[originalShader] = gpuShader;
                }
                else
                {
                    // HY_GrassDetailGpuInclude 찾아서 삽입
                    string[] includeGuids = AssetDatabase.FindAssets("HY_GrassDetailGpuInclude t:TextAsset");
                    if (includeGuids.Length == 0)
                    {
                        Debug.LogError("[GPUMode] Include 파일 'HY_GrassDetailGpuInclude.hlsl'을 찾을 수 없습니다.");
                        continue;
                    }
                    string includePath = AssetDatabase.GUIDToAssetPath(includeGuids[0]).Replace("\\", "/");

                    string newShaderPath = Path.Combine(folder, baseShaderName + "(GPUMode).shader").Replace("\\", "/");

                    string[] lines = File.ReadAllLines(shaderPath);
                    List<string> modifiedLines = new();

                    bool alreadyHasInclude = lines.Any(l => l.Contains("HY_GrassDetailGpuInclude"));
                    bool alreadyHasPragma1 = lines.Any(l => l.Contains("instancing_options procedural:setup"));
                    bool alreadyHasPragma2 = lines.Any(l => l.Contains("multi_compile PROCEDURAL_INSTANCING_ON"));

                    string newShaderName = ExtractShaderName(string.Join("\n", lines)) + "(GPUMode)";
                    bool nameChanged = false;
                    bool insertedToFirstHLSL = false;

                    foreach (var line in lines)
                    {
                        string trimmed = line.Trim();

                        if (!nameChanged && trimmed.StartsWith("Shader \""))
                        {
                            modifiedLines.Add($"Shader \"{newShaderName}\"");
                            nameChanged = true;
                            continue;
                        }

                        modifiedLines.Add(line);

                        if (!insertedToFirstHLSL && trimmed == "HLSLPROGRAM")
                        {
                            if (!alreadyHasPragma1)
                                modifiedLines.Add("#pragma instancing_options procedural:setup");

                            if (!alreadyHasPragma2)
                                modifiedLines.Add("#pragma multi_compile PROCEDURAL_INSTANCING_ON");

                            if (!alreadyHasInclude)
                                modifiedLines.Add($"#include \"{includePath}\"");
                        }
                    }

                    if (File.Exists(newShaderPath))
                        AssetDatabase.DeleteAsset(newShaderPath);

                    File.WriteAllLines(newShaderPath, modifiedLines);
                    AssetDatabase.ImportAsset(newShaderPath);

                    gpuShader = AssetDatabase.LoadAssetAtPath<Shader>(newShaderPath);
                    if (gpuShader == null)
                    {
                        Debug.LogError($"[GPUMode] 쉐이더 Import 실패: {newShaderPath}");
                        continue;
                    }

                    shaderCache[originalShader] = gpuShader;
                }
            }

            // GPU Material 생성
            string originalMatPath = AssetDatabase.GetAssetPath(originalMat);
            string folderPath = Path.GetDirectoryName(originalMatPath);
            string newMatPath = Path.Combine(folderPath, originalMat.name + "(GPUMode).mat").Replace("\\", "/");

            // 🎯 기존 머티리얼 존재 시 삭제
            if (AssetDatabase.LoadAssetAtPath<Material>(newMatPath) != null)
            {
                AssetDatabase.DeleteAsset(newMatPath);
                AssetDatabase.Refresh(); // 삭제 반영
            }

            // 새 GPU 머티리얼 생성
            Material gpuMat = new Material(originalMat) {
                name = originalMat.name + "(GPUMode)",
                shader = gpuShader
            };

            AssetDatabase.CreateAsset(gpuMat, newMatPath);
            AssetDatabase.SaveAssets();

            materialCache[originalMat] = gpuMat;

        }

        // 3️⃣ Pass 3: 렌더러에 GPU 머티리얼 교체
        foreach (var typeData in data.grassTypes)
        {
            foreach (var lod in typeData.lodLevels)
            {
                foreach (var renderer in lod.renderers)
                {
                    var originalMat = renderer.material;
                    if (originalMat == null || originalMat.name.Contains("(GPUMode)")) continue;

                    if (materialCache.TryGetValue(originalMat, out var gpuMat))
                    {
                        renderer.material = gpuMat;
                    }
                }
            }
        }

        EditorUtility.SetDirty(data);
    }


    private string ExtractShaderName(string shaderCode)
    {
        var match = Regex.Match(shaderCode, @"Shader\s+""(.+?)""");
        return match.Success ? match.Groups[1].Value : "Unknown/Shader";
    }


    private void RestoreOriginalMaterials(GrassDataList data)
    {
        List<string> matPathsToDelete = new();
        HashSet<string> shaderPathsToDelete = new();

        foreach (var typeData in data.grassTypes)
        {
            foreach (var lod in typeData.lodLevels)
            {
                foreach (var renderer in lod.renderers)
                {
                    var mat = renderer.material;
                    if (mat == null) continue;

                    string matPath = AssetDatabase.GetAssetPath(mat);
                    string folder = Path.GetDirectoryName(matPath);
                    string fileName = Path.GetFileNameWithoutExtension(matPath);

                    if (!fileName.EndsWith("(GPUMode)")) continue;

                    string baseFileName = fileName.Replace("(GPUMode)", "");
                    string originalMatPath = Path.Combine(folder, baseFileName + ".mat").Replace("\\", "/");

                    Material originalMat = AssetDatabase.LoadAssetAtPath<Material>(originalMatPath);

                    if (originalMat == null)
                    {
                        string[] allMatGuids = AssetDatabase.FindAssets("t:Material", new[] { folder });
                        foreach (var guid in allMatGuids)
                        {
                            string path = AssetDatabase.GUIDToAssetPath(guid);
                            string name = Path.GetFileNameWithoutExtension(path);
                            if (name == baseFileName)
                            {
                                originalMat = AssetDatabase.LoadAssetAtPath<Material>(path);
                                break;
                            }
                        }
                    }

                    if (originalMat != null)
                    {
                        renderer.material = originalMat;

                        if (!matPathsToDelete.Contains(matPath))
                            matPathsToDelete.Add(matPath);

                        Shader shader = mat.shader;
                        if (shader != null)
                        {
                            string shaderPath = AssetDatabase.GetAssetPath(shader);

                            if (!string.IsNullOrEmpty(shaderPath) &&
                                shaderPath.EndsWith(".shader") &&  
                                Path.GetFileNameWithoutExtension(shaderPath).EndsWith("(GPUMode)")) 
                            {
                                shaderPathsToDelete.Add(shaderPath);
                            }
                        }

                    }
                    else
                    {
                        Debug.LogWarning($"[Grass Restore] 원본 매터리얼을 찾을 수 없습니다: {originalMatPath}");
                    }
                }
            }
        }

        EditorUtility.SetDirty(data);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    private void ShowShaderGraphWarnings(GrassTypeData typeData)
    {
        if (typeData == null || typeData.lodLevels == null)
            return;

        foreach (var lod in typeData.lodLevels)
        {
            if (lod.renderers == null) continue;

            foreach (var renderer in lod.renderers)
            {
                var mat = renderer.material;
                if (mat == null || mat.shader == null) continue;

                string shaderPath = AssetDatabase.GetAssetPath(mat.shader);
                if (!string.IsNullOrEmpty(shaderPath) && shaderPath.EndsWith(".shadergraph"))
                {
                    string fileName = Path.GetFileNameWithoutExtension(shaderPath);
                    if (!fileName.Contains("(GPUMode)"))
                    {
                        EditorGUILayout.BeginVertical();
                        EditorGUILayout.HelpBox(
                            "Shader Graph 기반 쉐이더입니다." +
                            "\nShader Graph는 Draw Mesh Instanced Indirect 전용 쉐이더로 자동변환이 불가능합니다.", MessageType.Warning
                        );
                        EditorGUILayout.EndVertical();
                        return; 
                    }
                }
            }
        }
    }

    private void GrassDataTypePrefabRemove(GrassDataList grassDataList, GrassTypeData typeData)
    {
        var targetPrefab = typeData.prefab;

        grassDataList.grassTypes.Remove(typeData);

        foreach (var zone in grassDataList.zones)
        {
            zone.instanceGroups.RemoveAll(group => group.prefab == targetPrefab);
        }

        EditorUtility.SetDirty(grassDataList);
        AssetDatabase.SaveAssets();

        GUIUtility.ExitGUI(); 
    }

}

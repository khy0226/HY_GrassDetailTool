using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.IO;

public class HY_GrassDetailTool : EditorWindow
{
    private enum Tab { Painting, Bake }
    private Tab currentTab = Tab.Painting;

    private enum BakeTabMode { Hierarchy, Terrain }
    private BakeTabMode currentBakeTab = BakeTabMode.Hierarchy;
    List<Terrain> terrainTargets = new List<Terrain>();
    private Vector2 scrollPosTerrain;

    private bool terrainRotateToSlope = true;
    private bool grassCrossMesh = true;
    private string grassSavePath = "Assets";
    private bool terrainYOffset = false;
    private float terrainYOffsetMin = -0.01f;
    private float terrainYOffsetMax = -0.05f;

    private bool showDetails = false; // 목록 펼치기 여부
    private Vector2 scrollPos; // 스크롤 위치 저장
    private int iconSize = 60;
    private List<GameObject> pendingObjects = new List<GameObject>();

    private List<GameObject> grassPrefabs = new List<GameObject>();
    private int selectedPrefabIndex = -1;
    private bool isPlanting = false;
    private int targetLayer = 0;
    private int currentTargetLayer = -1;

    private GrassDataList grassDataList;

    private float plantingStartTime = 0f;  // 심기 시작 시간
    private float autoDisableTime = 60f;  // 자동 비활성화 시간

    private Vector3 lastPlantedPosition = Vector3.positiveInfinity;

    private GameObject temporaryObjectsParent;

    private const float MAX_PAINTED_DENSITY_IN_CELL = 255;

    [HideInInspector]private bool isGrassUpdatePending = false;

    private Vector2 scrollPositionBrush;
    private float brushSize = 1f;
    private bool brushSizeFoldout = false;
    private float brushSizeMax = 30f;
    private float paintDistance = 1f;
    private bool paintDistanceFoldout = false;
    private float paintDistanceMax = 10f;
    private int prefabDensity = 1;
    private bool prefabDensityFoldout = false;
    private int prefabDensityMax = 10;
    private bool slopeAngle = false;
    private float slopeAngleMin = 0f;
    private float slopeAngleMax = 0f;
    private bool prefabOffset = false;
    private Vector3 prefabOffsetMin = new Vector3(0, 0, 0);
    private Vector3 prefabOffsetMax = new Vector3(0, 0, 0);
    private bool prefabRotation = false;
    private Vector3 prefabRotationMin = new Vector3(0, 0, 0);
    private Vector3 prefabRotationMax = new Vector3(0, 0, 0);
    private bool rotateToSlope = true;
    private float prefabScaleSingleMin = 1f;
    private float prefabScaleSingleMax = 1f;
    private Vector3 prefabScaleMultiMin = new Vector3(1, 1, 1);
    private Vector3 prefabScaleMultiMax = new Vector3(1, 1, 1);
    private enum PrefabScaleMode{ Single , Multi };
    PrefabScaleMode prefabScale = PrefabScaleMode.Single;

    private float overlapPreventionSingle = 1;
    private Vector3 overlapPreventionMulti = new Vector3(1, 1, 1);
    private enum OverlapPreventionMode { None, Single, Multi }
    OverlapPreventionMode overlapPrevention = OverlapPreventionMode.None;

    [MenuItem("HY/Grass Detail Tool")]
    public static void ShowWindow()
    {
        // 창 생성
        HY_GrassDetailTool window = GetWindow<HY_GrassDetailTool>("Grass Detail Tool");

        // 초기 크기 설정
        window.position = new Rect(200, 200, 400, 600); // 초기 위치와 크기 지정
        window.minSize = new Vector2(200, 200);         // 최소 크기 설정
    }

    private void OnEnable()
    {
        SceneView.duringSceneGui += OnSceneGUI;
        Debug.Log("HY_GrassDetailTool 활성화됨!");
    }

    private void OnDisable()
    {
        SceneView.duringSceneGui -= OnSceneGUI;
        Debug.Log("HY_GrassDetailTool 비활성화됨!");
    }

    private void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Toggle(currentTab == Tab.Painting, "Painting", "Button"))
            currentTab = Tab.Painting;
        if (GUILayout.Toggle(currentTab == Tab.Bake, "Bake", "Button"))
            currentTab = Tab.Bake;
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        GrassDataSaveLoad();

        EditorGUILayout.Space();

        switch (currentTab)
        {
            case Tab.Painting:
                PaintingTab();
                break;
            case Tab.Bake:
                BakeTab();
                break;
        }
    }

    private void PaintingTab()
    {
        GUILayout.Label("드래그앤 드롭으로 프리팹을 넣어주세요", EditorStyles.boldLabel);

        // 드래그 감지를 위한 변수
        Event evt = Event.current;
        Rect prefabListArea;

        // 프리팹 목록을 감싸는 박스 (여기가 드래그 앤 드롭 영역)
        GUILayout.BeginVertical("box");
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("등록된 프리팹", EditorStyles.boldLabel);
        iconSize = Mathf.RoundToInt(GUILayout.HorizontalSlider(iconSize, 20, 100, GUILayout.Width(40)));
        EditorGUILayout.EndHorizontal();
        // 스크롤 뷰에서 프리팹 목록 표시
        scrollPos = GUILayout.BeginScrollView(scrollPos, GUILayout.Height(120));

        for (int i = 0; i < grassPrefabs.Count; i++)
        {
            // 선택된 프리팹을 시각적으로 강조
            Color originalColor = GUI.backgroundColor;
            if (i == selectedPrefabIndex)
            {
                GUI.backgroundColor = Color.cyan; // 선택된 프리팹의 박스 배경색
            }

            EditorGUILayout.BeginHorizontal("box");

            // 프리팹 미리보기 아이콘
            Texture2D preview = AssetPreview.GetAssetPreview(grassPrefabs[i]);
            if (GUILayout.Button(preview ?? EditorGUIUtility.IconContent("Prefab Icon").image, GUILayout.Width(iconSize), GUILayout.Height(iconSize)))
            {
                SelectPrefab(i);
            }

            GUILayout.Label(grassPrefabs[i].name, GUILayout.ExpandWidth(true));

            // 삭제 버튼
            if (GUILayout.Button("X", GUILayout.Width(20)))
            {
                RemovePrefab(i);
                GUI.changed = true;
                EditorWindow.GetWindow<EditorWindow>().Repaint();
            }

            EditorGUILayout.EndHorizontal();

            // 배경색 원래대로 복구
            GUI.backgroundColor = originalColor;
        }

        GUILayout.EndScrollView(); 

        prefabListArea = GUILayoutUtility.GetLastRect(); 
        GUILayout.EndVertical();

        // 드래그 앤 드롭 감지 (목록 박스 전체에서)
        if (evt.type == EventType.DragUpdated || evt.type == EventType.DragPerform)
        {
            if (prefabListArea.Contains(evt.mousePosition))
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();
                    foreach (var obj in DragAndDrop.objectReferences)
                    {
                        if (obj is GameObject prefab)
                        {
                            grassPrefabs.Add(prefab);
                            GUI.changed = true;
                        }
                    }
                }
                Event.current.Use();
            }
        }

        scrollPositionBrush = GUILayout.BeginScrollView(scrollPositionBrush);
        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        brushSize = EditorGUILayout.Slider("Brush Size", brushSize, 1f, brushSizeMax);
        brushSizeFoldout = EditorGUILayout.Foldout(brushSizeFoldout, "Max Brush Size");
        if (brushSizeFoldout)
        {
            brushSizeMax = EditorGUILayout.FloatField(brushSizeMax);
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        paintDistance = EditorGUILayout.Slider("Prefab Distance", paintDistance, 0.1f, paintDistanceMax);
        paintDistanceFoldout = EditorGUILayout.Foldout(paintDistanceFoldout, "Max Prefab Distance");
        if (paintDistanceFoldout)
        {
            paintDistanceMax = EditorGUILayout.FloatField(paintDistanceMax);
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        prefabDensity = EditorGUILayout.IntSlider("Prefab Density", prefabDensity, 1, prefabDensityMax);
        prefabDensityFoldout = EditorGUILayout.Foldout(prefabDensityFoldout, "Max Prefab Density");
        if (prefabDensityFoldout)
        {
            prefabDensityMax = EditorGUILayout.IntField(prefabDensityMax);
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        GUILayout.Label("Offset");
        prefabOffset = EditorGUILayout.Toggle("Random", prefabOffset);
        if (prefabOffset)
        {
            prefabOffsetMin = EditorGUILayout.Vector3Field("Min Offset", prefabOffsetMin);
            prefabOffsetMax = EditorGUILayout.Vector3Field("Max Offset", prefabOffsetMax);
        }
        else
        {
            prefabOffsetMax = EditorGUILayout.Vector3Field("", prefabOffsetMax);
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        GUILayout.Label("Rotation");
        prefabRotation = EditorGUILayout.Toggle("Random", prefabRotation);
        if (prefabRotation)
        {
            prefabRotationMin = EditorGUILayout.Vector3Field("Min Rotation", prefabRotationMin);
            prefabRotationMax = EditorGUILayout.Vector3Field("Max Rotation", prefabRotationMax);
        }
        else
        {
            prefabRotationMax = EditorGUILayout.Vector3Field("", prefabRotationMax);
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        rotateToSlope = EditorGUILayout.Toggle("Rotate To Slope", rotateToSlope);
        GUILayout.EndVertical();
        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        slopeAngle = EditorGUILayout.Toggle("Slope Angle", slopeAngle);
        if (slopeAngle)
        {       
            EditorGUILayout.BeginHorizontal();
            slopeAngleMin = Mathf.Round(slopeAngleMin * 100f) / 100f;
            slopeAngleMax = Mathf.Round(slopeAngleMax * 100f) / 100f;
            slopeAngleMin = Mathf.Clamp(slopeAngleMin, 0f, slopeAngleMax);
            slopeAngleMax = Mathf.Clamp(slopeAngleMax, slopeAngleMin, 90f);

            slopeAngleMin = EditorGUILayout.FloatField(slopeAngleMin, GUILayout.Width(40));
            EditorGUILayout.MinMaxSlider(ref slopeAngleMin, ref slopeAngleMax, 0f, 90);
            slopeAngleMax = EditorGUILayout.FloatField(slopeAngleMax, GUILayout.Width(40));
            EditorGUILayout.EndHorizontal();
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        prefabScale = (PrefabScaleMode)EditorGUILayout.EnumPopup("Prefab Scale", prefabScale);
        switch (prefabScale)
        {
            case PrefabScaleMode.Single:
                prefabScaleSingleMin = EditorGUILayout.FloatField("Min Scale", prefabScaleSingleMin);
                prefabScaleSingleMax = EditorGUILayout.FloatField("Max Scale", prefabScaleSingleMax);
                break;
            case PrefabScaleMode.Multi:
                prefabScaleMultiMin = EditorGUILayout.Vector3Field("Min Scale", prefabScaleMultiMin);
                prefabScaleMultiMax = EditorGUILayout.Vector3Field("Max Scale", prefabScaleMultiMax);
                break;
        }
        GUILayout.EndVertical();

        GUILayout.Space(5);
        GUILayout.BeginVertical("box");
        overlapPrevention = (OverlapPreventionMode)EditorGUILayout.EnumPopup("Overlap Prevention", overlapPrevention);
        switch (overlapPrevention)
        {
            case OverlapPreventionMode.Single:
                overlapPreventionSingle = EditorGUILayout.Slider("Scale", overlapPreventionSingle, 0, 2);
                break;
            case OverlapPreventionMode.Multi:
                overlapPreventionMulti.x = EditorGUILayout.Slider("Scale X", overlapPreventionMulti.x, 0, 2);
                overlapPreventionMulti.y = EditorGUILayout.Slider("Scale Y", overlapPreventionMulti.y, 0, 2);
                overlapPreventionMulti.z = EditorGUILayout.Slider("Scale Z", overlapPreventionMulti.z, 0, 2);
                break;
        }
        GUILayout.EndVertical();
        GUILayout.Space(5);

        GUILayout.EndScrollView();

        GUILayout.FlexibleSpace();

        targetLayer = EditorGUILayout.LayerField("Brush Layer", targetLayer);
        UpdateTargetLayer(targetLayer);

        // 심기 버튼
        if (GUILayout.Button(isPlanting ? "브러쉬 비활성화" : "브러쉬 활성화"))
        {
            if (isPlanting)
            {
                DisablePlantingMode();
            }
            else
            {
                EnablePlantingMode();
            }
        }
        GUILayout.Space(5);
        // 선택된 프리팹 및 심기 상태 표시
        if (selectedPrefabIndex >= 0)
        {
            GUILayout.Label("선택된 프리팹: " + grassPrefabs[selectedPrefabIndex].name);
            GUILayout.Label("심기 상태: " + (isPlanting ? "활성화" : "비활성화"));
        }
    }

    private void BakeTab()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Toggle(currentBakeTab == BakeTabMode.Hierarchy, "Hierarchy", "Button"))
            currentBakeTab = BakeTabMode.Hierarchy;
        if (GUILayout.Toggle(currentBakeTab == BakeTabMode.Terrain, "Terrain", "Button"))
            currentBakeTab = BakeTabMode.Terrain;
        EditorGUILayout.EndHorizontal();


        switch (currentBakeTab)
        {
            case BakeTabMode.Hierarchy:
                BakeTabHierarchy();
                break;
            case BakeTabMode.Terrain:
                BakeTabTerrain();
                break;
        }
    }

    private void BakeTabHierarchy()
    {
        GUILayout.BeginVertical("box");
        GUILayout.Label("여기로 오브젝트를 드래그하세요", EditorStyles.centeredGreyMiniLabel, GUILayout.Height(100));
        Rect dropArea = GUILayoutUtility.GetLastRect();
        EditorGUILayout.EndVertical();
        Event evt = Event.current;
        switch (evt.type)
        {
            case EventType.DragUpdated:
            case EventType.DragPerform:
                if (!dropArea.Contains(evt.mousePosition))
                    break;

                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();
                    foreach (Object obj in DragAndDrop.objectReferences)
                    {
                        GameObject go = obj as GameObject;
                        if (go != null)
                        {
                            // 부모는 제외하고, 하위 오브젝트들에서 "최상위 프리팹들만" 등록
                            List<GameObject> directPrefabs = GetOnlyDirectChildPrefabs(go);

                            foreach (GameObject prefab in directPrefabs)
                            {
                                if (!pendingObjects.Contains(prefab)) // 중복 추가 방지
                                {
                                    pendingObjects.Add(prefab);
                                }
                            }
                        }
                    }
                    evt.Use();
                }

                break;
        }

        // 등록된 개수만 표시
        GUILayout.Label($"등록된 오브젝트 개수: {pendingObjects.Count} 개");

        // "펼치기 / 접기" 버튼
        if (pendingObjects.Count > 0)
        {
            if (GUILayout.Button(showDetails ? "▲ 목록 접기" : "▼ 목록 펼치기"))
            {
                showDetails = !showDetails;
            }
        }

        // 펼치기 버튼을 눌렀을 때만 목록 표시
        if (showDetails)
        {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.Height(200));
            for (int i = 0; i < pendingObjects.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label(pendingObjects[i].name, GUILayout.Width(200));
                if (GUILayout.Button("X", GUILayout.Width(20)))
                {
                    pendingObjects.RemoveAt(i);
                    break; // 리스트 변경 시 foreach 중단
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }

        // "잔디 데이터로 변환" 버튼 (실제 변환 실행)
        if (GUILayout.Button("잔디 데이터로 변환"))
        {
            BakeGrassFromObjects();
        }

        // 전체 제거 버튼
        if (GUILayout.Button("목록 비우기"))
        {
            pendingObjects.Clear();
        }
    }

    private void BakeTabTerrain()
    {
        TerrainDragDropUI();

        GUILayout.Space(5);
        EditorGUILayout.BeginHorizontal();
        grassSavePath = EditorGUILayout.TextField(new GUIContent("Save Path", "텍스처 기반 잔디의 경우, 프리팹, 메쉬, 매트리얼을 저장할 위치를 지정합니다."), grassSavePath);

        if (GUILayout.Button("...", GUILayout.Width(30)))
        {
            string selectedPath = EditorUtility.OpenFolderPanel("Select Save Folder", grassSavePath, "");
            if (!string.IsNullOrEmpty(selectedPath))
            {
                if (selectedPath.StartsWith(Application.dataPath))
                {
                    grassSavePath = "Assets" + selectedPath.Substring(Application.dataPath.Length);
                }
                else
                {
                    Debug.LogWarning("저장 경로는 프로젝트 내부여야 합니다.");
                }
            }
        }
        EditorGUILayout.EndHorizontal();

        grassCrossMesh = EditorGUILayout.Toggle(new GUIContent("Cross Mesh", "텍스처 기반 잔디의 경우, 두 장의 평면이 교차된 십자가 형태(크로스 플랜)로 생성합니다."), grassCrossMesh);
        terrainRotateToSlope = EditorGUILayout.Toggle(new GUIContent("Rotate To Slope", "지형의 경사면을 따라 잔디 디테일을 기울어지도록 배치합니다."), terrainRotateToSlope);

        terrainYOffset = EditorGUILayout.Toggle(new GUIContent("Y Offset", "잔디 디테일의 깊이를 조절합니다."), terrainYOffset);
        if (terrainYOffset)
        {
            GUILayout.BeginVertical("box");
            terrainYOffsetMin = EditorGUILayout.FloatField(new GUIContent("Min", "잔디 디테일의 깊이를 조절합니다."), terrainYOffsetMin);
            terrainYOffsetMax = EditorGUILayout.FloatField(new GUIContent("Max", "잔디 디테일의 깊이를 조절합니다."), terrainYOffsetMax);
            GUILayout.EndVertical();
            GUILayout.Space(5);
        }

        GUILayout.Space(5);
        if (GUILayout.Button("데이터로 변환"))
        {
            TerrainGrassDetailBake();
        }

        if (terrainTargets.Count > 0)
        {
            int estimated = EstimateTotalGrassCount();
            string formatted = estimated.ToString("N0");
            EditorGUILayout.HelpBox($"예상 잔디 디테일 수: {formatted} 개", MessageType.None);

            if (estimated > 200_000)
            {
                EditorGUILayout.HelpBox("예상 잔디 디테일 수가 너무 많습니다. 성능에 영향이 있을 수 있습니다.", MessageType.Info);
            }
        }

        bool showDetailResolutionWarning = false;

        foreach (var terrain in terrainTargets)
        {
            TerrainData tData = terrain.terrainData;

            if (tData.detailResolution > tData.size.x)
            {
                showDetailResolutionWarning = true;
                break; 
            }
        }

        if (showDetailResolutionWarning)
        {
            EditorGUILayout.HelpBox(
                "Detail Resolution이 너무 높습니다." +
                "\n터레인 디테일과 시각적으로 차이가 날 수 있으니 주의하세요.", MessageType.Info);
        }
    }

    private void TerrainGrassDetailBake()
    {
        if (grassDataList == null)
        {
            Debug.LogError("GrassDataList가 설정되어 있지 않습니다!");
            return;
        }

        int totalConverted = 0;
        int currentBatchCount = 0; 
        int saveBatchSize = 20000;

        string toolRootPath = GetFolderOfThisScript();
        string meshFolder = Path.Combine(toolRootPath, "mesh");
        string planePath = Path.Combine(meshFolder, "Grass_Plane.mesh").Replace("\\", "/");
        string crossPath = Path.Combine(meshFolder, "Grass_Cross.mesh").Replace("\\", "/");

        foreach (var terrain in terrainTargets)
        {
            if (terrain == null || terrain.terrainData == null) 
            {
                Debug.LogWarning("타겟 터레인 또는 터레인 데이터가 null입니다. 건너뜁니다.");
                continue;
            }

            TerrainData tData = terrain.terrainData;
            Vector3 terrainPos = terrain.transform.position;

            int detailResolution = tData.detailResolution;
            float cellSize = tData.size.x / detailResolution;

            for (int i = 0; i < tData.detailPrototypes.Length; i++)
            {
                var proto = tData.detailPrototypes[i];
                if (proto.prototypeTexture == null && proto.prototype == null) continue;

                GameObject prefab;
                if (proto.usePrototypeMesh)
                {
                    prefab = proto.prototype;
                }
                else
                {
                    Mesh mesh = AssetDatabase.LoadAssetAtPath<Mesh>(grassCrossMesh ? crossPath : planePath);
                    if (mesh == null)
                    {
                        Debug.LogError("메쉬 로드 실패: " + (grassCrossMesh ? crossPath : planePath));
                        continue;
                    }

                    Material mat = CreateGrassMaterial(proto.prototypeTexture, grassSavePath, true);
                    prefab = CreateGrassPrefab(grassSavePath, proto.prototypeTexture.name + "_Grass", mesh, mat);
                }

                if (!grassPrefabs.Contains(prefab))
                    grassPrefabs.Add(prefab);

                if (!grassDataList.grassTypes.Any(g => g.prefab == prefab))
                {
                    GrassTypeData grassType = new GrassTypeData { prefab = prefab, hasShadow = false };
                    grassType.LoadLODFromPrefab();
                    grassDataList.grassTypes.Add(grassType);
                }

                float basePrefabSize = proto.prototype == null ? 1f : GetPrefabVisualSize(prefab); 
                float scaleFromProto = Mathf.Max((proto.minWidth + proto.maxWidth) * 0.5f, 0.01f);
                float visualSize = basePrefabSize * scaleFromProto;

                float cellArea = cellSize * cellSize; 

                float prefabArea = Mathf.Max(visualSize * visualSize, 0.0001f);
                float baseCount = (prefabArea > 0) ? (cellArea / prefabArea) : cellArea / 0.01f;

                float prototypeDensitySetting = Mathf.Clamp(proto.density, 0.01f, 3f); 
                int perCellCountFromProto = Mathf.Clamp(Mathf.RoundToInt(baseCount * Mathf.Pow(prototypeDensitySetting, 2f)), 1, 255);

                int detailWidth = tData.detailWidth;
                int detailHeight = tData.detailHeight;
                int[,] detailLayer = tData.GetDetailLayer(0, 0, detailWidth, detailHeight, i);

                for (int y = 0; y < detailHeight; y++)
                {
                    for (int x = 0; x < detailWidth; x++)
                    {
                        int paintedCellDensityValue = detailLayer[y, x];
                        if (paintedCellDensityValue == 0) continue; 

                        float currentMaxPaintedDensity = MAX_PAINTED_DENSITY_IN_CELL; 
                        float calculatedStrengthRatio = Mathf.Clamp01((float)paintedCellDensityValue / currentMaxPaintedDensity);
                        
                        int calculatedInstancesToPlace = Mathf.RoundToInt(perCellCountFromProto * calculatedStrengthRatio);

                        float strengthRatio = Mathf.Clamp01((float)paintedCellDensityValue / MAX_PAINTED_DENSITY_IN_CELL);
                        float strengthRatioAdjusted = Mathf.Pow(strengthRatio, 2f); // 기존 제곱 유지

                        float expectedCount = perCellCountFromProto * strengthRatioAdjusted;
                        int flooredInstanceCount = Mathf.FloorToInt(expectedCount);
                        float fractional = expectedCount - flooredInstanceCount;

                        int instancesToPlaceInThisCell = flooredInstanceCount;
                        if (Random.value < fractional)
                        {
                            instancesToPlaceInThisCell += 1;
                        }

                        bool placeThisDetailCell = true;
                        if (detailResolution > tData.size.x) 
                        {
                            float probabilityFactor = tData.size.x / detailResolution;
                            float spawnProbability = Mathf.Pow(probabilityFactor, 2.0f);

                            if (Random.value > spawnProbability)
                            {
                                placeThisDetailCell = false;
                            }
                        }

                        if (!placeThisDetailCell)
                        {
                            continue; 
                        }

                        for (int k = 0; k < instancesToPlaceInThisCell; k++)
                        {
                            float normalizedX = (x + Random.value) / detailWidth;
                            float normalizedZ = (y + Random.value) / detailHeight;

                            Vector3 pos = new Vector3(
                                terrainPos.x + normalizedX * tData.size.x,
                                0, 
                                terrainPos.z + normalizedZ * tData.size.z
                            );
                            pos.y = terrain.SampleHeight(pos) + terrainPos.y;

                            if (terrainYOffset)
                            {
                                pos.y += Random.Range(terrainYOffsetMin, terrainYOffsetMax);
                            }

                            Quaternion rot = Quaternion.identity;
                            if (terrainRotateToSlope || proto.alignToGround > 0.5f)
                            {
                                Vector3 normal = tData.GetInterpolatedNormal(normalizedX, normalizedZ);
                                rot = Quaternion.FromToRotation(Vector3.up, normal);
                            }
                            rot *= Quaternion.Euler(0, Random.Range(0f, 360f), 0f);

                            float width = Random.Range(proto.minWidth, proto.maxWidth);
                            float height = Random.Range(proto.minHeight, proto.maxHeight);
                            Vector3 scale = new Vector3(width, height, width); // 기존 방식 유지

                            GrassData grass = new GrassData {
                                position = pos,
                                rotation = rot,
                                scale = scale
                            };

                            bool added = grassDataList.AddToZoneInstanceGroup("_DefaultZone", prefab, grass);
                            if (added)
                            {
                                totalConverted++;
                                currentBatchCount++;
                            }

                            if (currentBatchCount >= saveBatchSize)
                            {
                                currentBatchCount = 0;
                                Debug.Log($"{terrain.name} 터레인 처리 중, 현재까지 {totalConverted}개 저장 중간처리...");
                                if (grassDataList != null) EditorUtility.SetDirty(grassDataList);
                            }
                        }
                    }
                }
            } 
        } 

        if (grassDataList != null)
        {
            grassDataList.lastSavedPath = grassSavePath;
            GrassDataListEditor.AutoDistributeDefaultZone(grassDataList); 
            EditorUtility.SetDirty(grassDataList);
        }

        ApplyGrassChanges(); 

        AssetDatabase.SaveAssets();
        Debug.Log($"변환 완료! 총 {totalConverted}개의 디테일이 실제 배치 데이터로 변환되었습니다.");
    }



private float GetPrefabVisualSize(GameObject prefab)
    {
        GameObject instance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
        if (!instance) return 1f;

        Bounds bounds = new Bounds();
        bool valid = false;

        var lodGroup = instance.GetComponentInChildren<LODGroup>();
        if (lodGroup != null)
        {
            var lods = lodGroup.GetLODs();
            if (lods.Length > 0 && lods[0].renderers.Length > 0)
            {
                bounds = lods[0].renderers[0].bounds;
                for (int i = 1; i < lods[0].renderers.Length; i++)
                    bounds.Encapsulate(lods[0].renderers[i].bounds);
                valid = true;
            }
        }

        if (!valid)
        {
            var renderers = instance.GetComponentsInChildren<Renderer>(true);
            if (renderers.Length == 0)
            {
                DestroyImmediate(instance);
                return 1f;
            }

            bounds = renderers[0].bounds;
            for (int i = 1; i < renderers.Length; i++)
                bounds.Encapsulate(renderers[i].bounds);
        }

        DestroyImmediate(instance);
        return Mathf.Max(bounds.size.x, bounds.size.z);
    }


    private bool IsOverlapping(Vector3 pos, List<Vector3> occupied, float threshold)
    {
        if (threshold <= 0f) return false;
        foreach (var p in occupied)
        {
            if (Vector3.Distance(p, pos) < threshold)
                return true;
        }
        return false;
    }

    private int EstimateTotalGrassCount()
    {
        double expectedTotal = 0; 

        foreach (var terrain in terrainTargets)
        {
            if (terrain == null || terrain.terrainData == null) continue;

            TerrainData tData = terrain.terrainData;
            int detailResolution = tData.detailResolution;

            float cellSize = tData.size.x / detailResolution;
            float cellAreaForEst = cellSize * cellSize;

            int detailWidth = tData.detailWidth;
            int detailHeight = tData.detailHeight;

            for (int i = 0; i < tData.detailPrototypes.Length; i++)
            {
                var proto = tData.detailPrototypes[i];
                if (proto.prototypeTexture == null && proto.prototype == null) continue;

                float basePrefabSizeForEst;
                if (proto.usePrototypeMesh && proto.prototype != null)
                {
                    basePrefabSizeForEst = GetPrefabVisualSize(proto.prototype); 
                }
                else
                { 
                    basePrefabSizeForEst = 1f; 
                }
                float scaleFromProtoForEst = Mathf.Max((proto.minWidth + proto.maxWidth) * 0.5f, 0.01f);
                float visualSizeForEst = basePrefabSizeForEst * scaleFromProtoForEst;

                float prefabAreaForEst = Mathf.Max(visualSizeForEst * visualSizeForEst, 0.0001f);
                float baseCountForEst = (prefabAreaForEst > 0) ? (cellAreaForEst / prefabAreaForEst) : cellAreaForEst / 0.01f;
                float prototypeDensitySettingForEst = Mathf.Clamp(proto.density, 0.01f, 3f);
                int perCellCountFromProto = Mathf.Clamp(Mathf.RoundToInt(baseCountForEst * Mathf.Pow(prototypeDensitySettingForEst, 2f)), 1, 255);

                int[,] detailLayer = tData.GetDetailLayer(0, 0, detailWidth, detailHeight, i);

                for (int y = 0; y < detailHeight; y++)
                {
                    for (int x = 0; x < detailWidth; x++)
                    {
                        int paintedCellDensityValue = detailLayer[y, x];
                        if (paintedCellDensityValue == 0) continue;

                        float strengthRatio = Mathf.Clamp01((float)paintedCellDensityValue / MAX_PAINTED_DENSITY_IN_CELL);
                        float strengthRatioSquare = strengthRatio * strengthRatio; 
                        double expectedInstancesAfterStrength = perCellCountFromProto * strengthRatioSquare;

                        if (expectedInstancesAfterStrength < 0.00001) continue; 

                        double finalExpectedInstancesForCell = expectedInstancesAfterStrength;
                        if (detailResolution > tData.size.x)
                        {
                            float probabilityFactor = tData.size.x / detailResolution;
                            float spawnProbability = Mathf.Pow(probabilityFactor, 2.0f);
                            finalExpectedInstancesForCell *= spawnProbability;
                        }

                        expectedTotal += finalExpectedInstancesForCell;
                    }
                }
            }
        }
        return Mathf.RoundToInt((float)expectedTotal); 
    }


    private void TerrainDragDropUI()
    {
        GUILayout.BeginVertical("box");
        EditorGUILayout.BeginHorizontal();
        if (terrainTargets.Count == 0)
        {
            GUILayout.Label("여기로 Terrain을 드래그하세요", EditorStyles.centeredGreyMiniLabel, GUILayout.Height(100));
        }
        else
        {
            GUILayout.Label("Terrain", EditorStyles.centeredGreyMiniLabel);
            if (GUILayout.Button("X", GUILayout.Width(20)))
                terrainTargets.Clear();
        }
        EditorGUILayout.EndHorizontal();

        Rect dropArea = GUILayoutUtility.GetLastRect();

        Event evt = Event.current;
        if ((evt.type == EventType.DragUpdated || evt.type == EventType.DragPerform) && dropArea.Contains(evt.mousePosition))
        {
            DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

            if (evt.type == EventType.DragPerform)
            {
                DragAndDrop.AcceptDrag();
                foreach (Object draggedObj in DragAndDrop.objectReferences)
                {
                    if (draggedObj is GameObject parent)
                    {
                        Terrain[] terrains = parent.GetComponentsInChildren<Terrain>();
                        foreach (var terrain in terrains)
                            if (terrain != null && !terrainTargets.Contains(terrain))
                            {
                                terrainTargets.Add(terrain);
                            }
                    }
                    else if (draggedObj is Terrain terrain)
                    {
                        if (terrain != null && !terrainTargets.Contains(terrain))
                        {
                            terrainTargets.Add(terrain);
                        }
                    }
                }
                evt.Use();
            }
        }
        if (terrainTargets.Count > 0)
        {
            scrollPosTerrain = EditorGUILayout.BeginScrollView(scrollPosTerrain, GUILayout.Height(80));
            for (int i = 0; i < terrainTargets.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(terrainTargets[i], typeof(Terrain), true);
                if (GUILayout.Button("X", GUILayout.Width(20)))
                {
                    terrainTargets.RemoveAt(i);
                    break;
                }
                EditorGUILayout.EndHorizontal();
            }
            GUILayout.Space(5);
            EditorGUILayout.EndScrollView();
        }
        GUILayout.EndVertical();
    }


    private void BakeGrassFromObjects()
    {
        if (grassDataList == null)
        {
            Debug.LogError("GrassDataList가 설정되지 않음!");
            return;
        }

        if (pendingObjects.Count == 0)
        {
            Debug.LogWarning("등록된 오브젝트가 없습니다!");
            return;
        }

        int count = 0;
        foreach (GameObject obj in pendingObjects)
        {
            GameObject prefab = PrefabUtility.GetCorrespondingObjectFromSource(obj);
            if (prefab == null) continue;

            // 프리팹 데이터 찾거나 생성
            GrassTypeData targetType = grassDataList.grassTypes.Find(t => t.prefab == prefab);
            if (targetType == null)
            {
                targetType = new GrassTypeData { prefab = prefab };
                grassDataList.grassTypes.Add(targetType);
            }

            // LOD 수집, 머티리얼 초기화, 그림자설정
            targetType.LoadLODFromPrefab();

            // 인스턴스 트랜스폼 저장
            GrassData newGrass = new GrassData {
                position = obj.transform.position,
                rotation = obj.transform.rotation,
                scale = obj.transform.localScale
            };

            if (grassDataList.AddToZoneInstanceGroup("_DefaultZone", targetType.prefab, newGrass))
            {
                count++;
            }
        }

        GrassDataListEditor.AutoDistributeDefaultZone(grassDataList);

        Debug.Log($"{count}개의 오브젝트가 잔디 데이터로 베이크 완료!");

        pendingObjects.Clear();
        RegisterLoadedPrefabs();
        ApplyGrassChanges();
    }

    private List<GameObject> GetAllChildPrefabs(GameObject parent)
    {
        List<GameObject> prefabs = new List<GameObject>();

        GameObject parentPrefab = PrefabUtility.GetCorrespondingObjectFromSource(parent);
        if (parentPrefab != null)
        {
            prefabs.Add(parent);
        }

        foreach (Transform child in parent.transform)
        {
            prefabs.AddRange(GetAllChildPrefabs(child.gameObject));
        }

        return prefabs;
    }

    private List<GameObject> GetOnlyChildPrefabs(GameObject parent)
    {
        List<GameObject> prefabs = new List<GameObject>();

        foreach (Transform child in parent.transform)
        {
            GameObject childPrefab = PrefabUtility.GetCorrespondingObjectFromSource(child.gameObject);
            if (childPrefab != null) 
            {
                prefabs.Add(child.gameObject);
            }

            prefabs.AddRange(GetOnlyChildPrefabs(child.gameObject));
        }

        return prefabs;
    }

    private List<GameObject> GetOnlyDirectChildPrefabs(GameObject go)
    {
        List<GameObject> result = new();

        // 1. 프리팹 루트면 자기 자신만 등록
        if (PrefabUtility.IsAnyPrefabInstanceRoot(go))
        {
            result.Add(go);
        }
        else
        {
            // 2. 프리팹 아니면 자식 중 프리팹 루트만 수집
            foreach (Transform child in go.transform)
            {
                if (PrefabUtility.IsAnyPrefabInstanceRoot(child.gameObject))
                {
                    result.Add(child.gameObject);
                }
            }
        }

        return result;
    }

    private List<GameObject> ExtractPrefabs(GameObject parent)
    {
        List<GameObject> prefabs = new List<GameObject>();

        foreach (Transform child in parent.transform)
        {
            GameObject prefab = PrefabUtility.GetCorrespondingObjectFromSource(child.gameObject);
            if (prefab != null) // 프리팹이 있는 오브젝트만 추가
            {
                if (!prefabs.Contains(prefab)) // 중복 방지
                {
                    prefabs.Add(prefab);
                }
            }

            // 자식 오브젝트들도 검사
            List<GameObject> childPrefabs = ExtractPrefabs(child.gameObject);
            foreach (GameObject childPrefab in childPrefabs)
            {
                if (!prefabs.Contains(childPrefab)) // 중복 방지
                {
                    prefabs.Add(childPrefab);
                }
            }
        }

        return prefabs;
    }

    private void GrassDataSaveLoad()
    {
        // GrassDataList를 드래그 앤 드롭으로 설정할 수 있는 ObjectField
        var newGrassDataList = (GrassDataList)EditorGUILayout.ObjectField(
            "Grass Data List",
            grassDataList,
            typeof(GrassDataList),
            false
        );

        // 변경 감지: 새로 설정된 GrassDataList가 있으면
        if (newGrassDataList != grassDataList)
        {
            grassDataList = newGrassDataList;

            if (grassDataList != null)
            {
                // 프리팹 등록 로직 호출
                RegisterLoadedPrefabs();
                grassSavePath = grassDataList.lastSavedPath;
            }

            EditorWindow.GetWindow<EditorWindow>().Repaint(); // UI 갱신
        }

        // 기타 저장, 불러오기, 초기화 버튼 등
        EditorGUILayout.BeginHorizontal();
        // 저장 & 불러오기 버튼 추가
        if (GUILayout.Button("새 데이터 생성"))
        {
            SaveGrassData();
        }

        if (GUILayout.Button("데이터 불러오기"))
        {
            LoadGrassData();
        }

        // 데이터 초기화 버튼 추가
        if (GUILayout.Button("데이터 초기화"))
        {
            ClearGrass();
        }
        EditorGUILayout.EndHorizontal();
    }

    private void UpdateTargetLayer(int newLayer)
    {
        if (newLayer != currentTargetLayer)
        {
            // 레이어 변경 시 임시 오브젝트 초기화
            currentTargetLayer = newLayer;
            RemoveTemporaryObjects();
            Debug.Log("타겟 레이어가 변경되었습니다: " + LayerMask.LayerToName(newLayer));
        }
    }

    private void CreateTemporaryObject(GameObject hitObj)
    {
        string tempName = hitObj.name + "(_Temporary)";
        Vector3 targetPos = hitObj.transform.position;

        // 임시 부모 생성
        string tempID = System.Guid.NewGuid().ToString("N").Substring(0, 6);
        string tempParentName = $"TemporaryObjectsParent_{tempID}";
        if (temporaryObjectsParent == null)
            temporaryObjectsParent = new GameObject(tempParentName);

        // 중복 방지: 이름뿐 아니라 위치까지 확인
        foreach (Transform child in temporaryObjectsParent.transform)
        {
            if (child.name == tempName && Vector3.Distance(child.position, targetPos) < 0.01f)
            {
                // 이미 같은 위치에 같은 이름의 임시 오브젝트가 존재하면 스킵
                return;
            }
        }

        // LOD0 메쉬 찾기
        MeshFilter mf = GetLOD0MeshFilter(hitObj);
        if (mf == null || mf.sharedMesh == null)
        {
            Debug.LogWarning("LOD0 Mesh를 찾을 수 없습니다: " + hitObj.name);
            return;
        }

        GameObject temp = new GameObject(tempName);
        temp.transform.SetParent(temporaryObjectsParent.transform);
        temp.transform.position = targetPos;
        temp.transform.rotation = hitObj.transform.rotation;
        temp.transform.localScale = hitObj.transform.lossyScale;

        MeshCollider collider = temp.AddComponent<MeshCollider>();
        collider.sharedMesh = mf.sharedMesh;

        temp.layer = targetLayer;

        Debug.Log($"임시 콜라이더 생성됨: {temp.name}");
    }

    private MeshFilter GetLOD0MeshFilter(GameObject obj)
    {
        LODGroup lodGroup = obj.GetComponentInChildren<LODGroup>();
        if (lodGroup != null)
        {
            LOD[] lods = lodGroup.GetLODs();
            if (lods.Length > 0)
            {
                foreach (Renderer r in lods[0].renderers)
                {
                    MeshFilter mf = r.GetComponent<MeshFilter>();
                    if (mf != null && mf.sharedMesh != null)
                    {
                        return mf;
                    }
                }
            }
        }

        // fallback: 일반 MeshFilter
        return obj.GetComponentInChildren<MeshFilter>();
    }

    private void RemoveTemporaryObjects()
    {
        var allTemps = GameObject.FindObjectsOfType<GameObject>().Where(go => go.name.StartsWith("TemporaryObjectsParent_")).ToArray();

        foreach (var temp in allTemps)
        {
            DestroyImmediate(temp);
        }

        temporaryObjectsParent = null;
    }

    private bool IsValidPaintTarget(GameObject obj)
    {
        bool isTerrain = obj.GetComponent<TerrainCollider>() != null;
        bool isTemp = obj.name.Contains("(_Temporary)");
        bool isTargetLayer = obj.layer == targetLayer;

        return (isTerrain && isTargetLayer) || isTemp;
    }

    private bool IsVisibleFromSceneCamera(Vector3 point, GameObject target, out GameObject occluder)
    {
        Camera cam = SceneView.currentDrawingSceneView.camera;
        Vector3 origin = cam.transform.position;
        Vector3 dir = point - origin;

        if (Physics.Raycast(origin, dir.normalized, out RaycastHit hit, dir.magnitude))
        {
            if (hit.collider.gameObject != target)
            {
                occluder = hit.collider.gameObject;
                return false;
            }
        }

        occluder = null;
        return true;
    }

    private bool IsOccludedButAcceptable(GameObject target, GameObject occluder)
    {
        // 거의 같은 위치일 경우 허용
        float distance = Vector3.Distance(target.transform.position, occluder.transform.position);
        if (distance < 0.01f)
            return true;

        // 같은 프리팹일 경우 허용
        GameObject rootA = PrefabUtility.GetNearestPrefabInstanceRoot(target);
        GameObject rootB = PrefabUtility.GetNearestPrefabInstanceRoot(occluder);
        return rootA != null && rootA == rootB;
    }

    private void OnSceneGUI(SceneView sceneView)
    {
#if UNITY_EDITOR
        // 브러쉬 활성화 시켜놓고 딴짓할때 gpu계속 도는거 신경쓰여서 백그라운드때 정지시킴
        if (!UnityEditorInternal.InternalEditorUtility.isApplicationActive)
            return;
#endif
        if (isPlanting && selectedPrefabIndex >= 0 && grassDataList != null)
        {
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
            Event evt = Event.current;
            Ray ray = HandleUtility.GUIPointToWorldRay(evt.mousePosition);

            RaycastHit[] hits = Physics.RaycastAll(ray, Mathf.Infinity);
            hits = hits.OrderBy(hit => hit.distance).ToArray();

            RaycastHit? closestPaintableHit = null;

            foreach (RaycastHit hit in hits)
            {
                GameObject hitObject = hit.collider.gameObject;

                // 조건: Terrain 또는 임시 오브젝트 제외
                bool isTerrain = hitObject.GetComponent<TerrainCollider>() != null;
                bool isTempCollider = hitObject.name.Contains("(_Temporary)");
                bool isTargetLayer = hitObject.layer == targetLayer;

                if (isTerrain || isTempCollider || !isTargetLayer)
                    continue;

                // 프리팹 루트 기준으로 임시 오브젝트 생성
                GameObject prefabRoot = PrefabUtility.GetNearestPrefabInstanceRoot(hitObject);
                if (prefabRoot == null)
                    prefabRoot = hitObject;

                MeshFilter[] meshFilters = prefabRoot.GetComponentsInChildren<MeshFilter>();
                LODGroup lodGroup = prefabRoot.GetComponentInChildren<LODGroup>();
                Transform[] lod0Objects = null;

                if (lodGroup != null)
                {
                    LOD[] lods = lodGroup.GetLODs();
                    lod0Objects = lods.Length > 0
                        ? lods[0].renderers.Select(r => r.transform).ToArray()
                        : new Transform[0];
                }

                foreach (var mf in meshFilters)
                {
                    GameObject meshObj = mf.gameObject;

                    if (lodGroup != null && !lod0Objects.Contains(meshObj.transform))
                        continue;

                    if (!meshObj.name.Contains("(_Temporary)"))
                    {
                        CreateTemporaryObject(meshObj);
                    }
                }

                break; // 가장 가까운 hit만 처리
            }

            foreach (RaycastHit hit in hits)
            {
                GameObject hitObject = hit.collider.gameObject;

                bool isTerrain = hitObject.GetComponent<TerrainCollider>() != null;
                bool isTempCollider = hitObject.name.Contains("(_Temporary)");
                bool isTargetLayer = hitObject.layer == targetLayer;

                if ((isTerrain && isTargetLayer) || isTempCollider)
                {
                    closestPaintableHit = hit;
                    break;
                }
            }

            if (closestPaintableHit.HasValue)
            {
                var hit = closestPaintableHit.Value;
                GameObject hitObject = hit.collider.gameObject;

                if (IsVisibleFromSceneCamera(hit.point, hitObject, out GameObject blocker))
                {
                    // 카메라에서 보임
                    Handles.color = Color.green;
                    Handles.DrawWireDisc(hit.point, hit.normal, brushSize);
                }
                else if (IsOccludedButAcceptable(hitObject, blocker))
                {
                    // 안 보이지만 "겹친 것"이면 허용
                    Handles.color = Color.green;
                    Handles.DrawWireDisc(hit.point, hit.normal, brushSize);
                }

                // 잔디 심기
                if ((evt.type == EventType.MouseDown || evt.type == EventType.MouseDrag) && evt.button == 0 && !evt.control)
                {
                    if (Vector3.Distance(lastPlantedPosition, hit.point) >= paintDistance)
                    {
                        float angle = Vector3.Angle(Vector3.up, hit.normal);
                        if (!slopeAngle || (angle >= slopeAngleMin && angle <= slopeAngleMax))
                        {
                            GameObject selectedPrefab = grassPrefabs[selectedPrefabIndex];
                            GrassTypeData selectedGrassType = grassDataList.grassTypes.Find(t => t.prefab == selectedPrefab);
                            if (selectedGrassType == null)
                            {
                                selectedGrassType = new GrassTypeData { prefab = selectedPrefab };
                                grassDataList.grassTypes.Add(selectedGrassType);
                            }

                            for (int i = 0; i < prefabDensity; i++)
                            {
                                Vector3 brushXZOffset = prefabDensity > 1
                                    ? new Vector3(Random.Range(-brushSize, brushSize), 0, Random.Range(-brushSize, brushSize))
                                    : Vector3.zero;

                                Vector3 baseOffset = prefabOffset
                                    ? new Vector3(
                                        Random.Range(prefabOffsetMin.x, prefabOffsetMax.x),
                                        Random.Range(prefabOffsetMin.y, prefabOffsetMax.y),
                                        Random.Range(prefabOffsetMin.z, prefabOffsetMax.z))
                                    : prefabOffsetMax;

                                Vector3 rayOrigin = hit.point + brushXZOffset + new Vector3(baseOffset.x, 0f, baseOffset.z) + hit.normal * 0.5f;
                                Vector3 rayDir = -hit.normal;

                                Ray rayFromNormal = new Ray(rayOrigin, rayDir);
                                RaycastHit[] allHits = Physics.RaycastAll(rayFromNormal, 2f);
                                RaycastHit? validHit = allHits
                                    .OrderBy(h => h.distance)
                                    .FirstOrDefault(h =>
                                    {
                                        GameObject obj = h.collider.gameObject;
                                        return IsValidPaintTarget(obj) &&
                                               (obj.name.Contains("(_Temporary)") || obj.GetComponent<TerrainCollider>() != null);
                                    });

                                if (!validHit.HasValue)
                                    continue;

                                RaycastHit randomHit = validHit.Value;
                                Vector3 correctedPosition = randomHit.point;
                                Vector3 normal = randomHit.normal;

                                Quaternion randomRotation = prefabRotation
                                    ? Quaternion.Euler(
                                        Random.Range(prefabRotationMin.x, prefabRotationMax.x),
                                        Random.Range(prefabRotationMin.y, prefabRotationMax.y),
                                        Random.Range(prefabRotationMin.z, prefabRotationMax.z))
                                    : Quaternion.identity;

                                if (rotateToSlope)
                                {
                                    Quaternion slopeRotation = Quaternion.FromToRotation(Vector3.up, normal);
                                    randomRotation = slopeRotation * randomRotation;
                                }

                                correctedPosition += randomRotation * Vector3.up * baseOffset.y;

                                Vector3 randomScale;
                                if (prefabScale == PrefabScaleMode.Single)
                                {
                                    float scaleValue = Random.Range(prefabScaleSingleMin, prefabScaleSingleMax);
                                    randomScale = new Vector3(scaleValue, scaleValue, scaleValue);
                                }
                                else
                                {
                                    randomScale = new Vector3(
                                        Random.Range(prefabScaleMultiMin.x, prefabScaleMultiMax.x),
                                        Random.Range(prefabScaleMultiMin.y, prefabScaleMultiMax.y),
                                        Random.Range(prefabScaleMultiMin.z, prefabScaleMultiMax.z));
                                }

                                // 중복 방지 체크
                                bool isValidPosition = true;

                                if (overlapPrevention != OverlapPreventionMode.None)
                                {
                                    foreach (var zone in grassDataList.zones)
                                    {
                                        foreach (var group in zone.instanceGroups)
                                        {
                                            if (group.prefab != selectedGrassType.prefab) continue;

                                            foreach (GrassData existingGrass in group.instances)
                                            {
                                                float distance = Vector3.Distance(existingGrass.position, correctedPosition);
                                                float requiredDistance = overlapPrevention == OverlapPreventionMode.Single
                                                    ? overlapPreventionSingle * randomScale.x
                                                    : new Vector3(
                                                        overlapPreventionMulti.x * randomScale.x,
                                                        overlapPreventionMulti.y * randomScale.y,
                                                        overlapPreventionMulti.z * randomScale.z).magnitude;

                                                if (distance < requiredDistance)
                                                {
                                                    isValidPosition = false;
                                                    break;
                                                }
                                            }

                                            if (!isValidPosition) break;
                                        }

                                        if (!isValidPosition) break;
                                    }
                                }

                                if (isValidPosition)
                                {
                                    PlantGrass(correctedPosition, randomRotation, randomScale);
                                }
                            }
                            lastPlantedPosition = hit.point;
                        }
                    }
                }

                // Ctrl 드래그로 잔디 제거
                if (evt.type == EventType.MouseDrag && evt.button == 0 && evt.control)
                {
                    RemoveGrassInBrushArea(hit.point, brushSize);
                }

                // 마우스 놓으면 심기 위치 초기화
                if (evt.type == EventType.MouseUp && evt.button == 0)
                {
                    lastPlantedPosition = Vector3.positiveInfinity;
                }
            }
            SceneView.RepaintAll();
        }
    }


    // 자동 비활성화 (Update()에서 실행)
    private void Update()
    {
        if (isPlanting)
        {
            // 정해진 시간 동안 아무 입력 없으면 자동으로 비활성화
            if (Time.time - plantingStartTime > autoDisableTime)
            {
                Debug.LogWarning("잔디 심기가 1분 동안 비활성 상태였으므로 자동 종료합니다.");
                DisablePlantingMode();
            }

            // 사용자 입력이 있거나 잔디 심기 작업 중일 때 타이머 초기화
            if (Input.anyKeyDown || Input.GetMouseButton(0) || IsPlantingAction())
            {
                plantingStartTime = Time.time; // 타이머 리셋
            }
        }
    }

    private bool IsPlantingAction()
    {
        // 특정 작업 상태(클릭/드래그)를 확인. 심기 작업 도중 true 반환.
        return isPlanting; // 필요하면 작업 체크 조건 추가
    }

    private void PlantGrass(Vector3 position, Quaternion rotation, Vector3 scale)
    {
        if (selectedPrefabIndex < 0 || selectedPrefabIndex >= grassPrefabs.Count)
        {
            Debug.LogWarning("선택된 프리팹이 없습니다!");
            return;
        }

        GameObject selectedPrefab = grassPrefabs[selectedPrefabIndex];

        // 프리팹 데이터 검색 or 생성
        GrassTypeData targetType = grassDataList.grassTypes.Find(t => t.prefab == selectedPrefab);
        if (targetType == null)
        {
            targetType = new GrassTypeData { prefab = selectedPrefab };
            grassDataList.grassTypes.Add(targetType);
        }

        // LOD 정보 로드 (mesh + material + shadow 수집)
        targetType.LoadLODFromPrefab();

        // 새로운 인스턴스 데이터 추가
        GrassData newGrass = new GrassData {
            position = position,
            rotation = rotation,
            scale = scale
        };

        // 존 등록
        grassDataList.AddToZoneInstanceGroup("_DefaultZone", targetType.prefab, newGrass);
        GrassDataListEditor.AutoDistributeDefaultZone(grassDataList);

        ApplyGrassChanges();
    }

    private void RemoveGrassInBrushArea(Vector3 center, float radius)
    {
        if (grassDataList == null)
        {
            Debug.LogError("GrassDataList가 설정되지 않았습니다!");
            return;
        }

        int removedCount = 0;

        // 제거할 프리팹 목록
        List<string> removedGroupNames = new List<string>();

        foreach (var zone in grassDataList.zones)
        {
            for (int g = zone.instanceGroups.Count - 1; g >= 0; g--)
            {
                var group = zone.instanceGroups[g];

                for (int i = group.instances.Count - 1; i >= 0; i--)
                {
                    GrassData instance = group.instances[i];
                    if (Vector3.Distance(instance.position, center) <= radius)
                    {
                        group.instances.RemoveAt(i);
                        removedCount++;
                    }
                }

                // 해당 그룹에 인스턴스가 하나도 없으면 그룹 삭제
                if (group.instances.Count == 0)
                {
                    removedGroupNames.Add(group.prefab.name);
                    zone.instanceGroups.RemoveAt(g);
                }
            }
        }

        if (removedCount > 0)
        {
            ApplyGrassChanges(); // 데이터 적용
        }
    }

    private void ApplyGrassChanges()
    {
        if (prefabDensity <= 1)
        {
            if (grassDataList == null) return;

#if UNITY_EDITOR
            EditorUtility.SetDirty(grassDataList);
#endif

            HY_GrassDetailRenderer renderer = FindObjectOfType<HY_GrassDetailRenderer>();
            if (renderer != null)
            {
                if (renderer.grassDataList != grassDataList)
                {
                    renderer.SetGrassData(grassDataList);
                }
                renderer.ForceEnableRender();
                renderer.ApplyInstanceUpdate();
                renderer.RenderGrass();
#if UNITY_EDITOR
                SceneView.RepaintAll(); 
#endif
            }
        }

        else
        {
            if (isGrassUpdatePending) return;
            isGrassUpdatePending = true;

            EditorApplication.delayCall += () =>
            {
                if (grassDataList == null) return;

#if UNITY_EDITOR
                EditorUtility.SetDirty(grassDataList);
#endif

                HY_GrassDetailRenderer renderer = FindObjectOfType<HY_GrassDetailRenderer>();
                if (renderer != null)
                {
                    if (renderer.grassDataList != grassDataList)
                        renderer.SetGrassData(grassDataList);

                    renderer.ForceEnableRender();
                    renderer.ApplyInstanceUpdate();
                    renderer.RenderGrass();

#if UNITY_EDITOR
                    SceneView.RepaintAll();
#endif
                }

                isGrassUpdatePending = false;
            };
        }
    }



    private void SelectPrefab(int index)
    {
        selectedPrefabIndex = index;
        Debug.Log("선택된 프리팹: " + grassPrefabs[index].name);
    }

    private void RemovePrefab(int index)
    {
        grassPrefabs.RemoveAt(index);
        if (selectedPrefabIndex == index)
        {
            selectedPrefabIndex = -1;
        }
    }
    public void EnablePlantingMode()
    {
        isPlanting = true;
        plantingStartTime = Time.time; // 시작 시간 저장
        RemoveTemporaryObjects();
    }

    public void DisablePlantingMode()
    {
        isPlanting = false;
        Debug.Log("잔디 심기 비활성화됨!");
        RemoveTemporaryObjects();
    }

    private void SaveGrassData()
    {
        // 탐색기를 열어 사용자가 원하는 경로를 선택하도록 함
        string path = EditorUtility.SaveFilePanelInProject(
            "Save Grass Data",          // 창 제목
            "GrassDataList",             // 기본 파일명
            "asset",                     // 파일 확장자
            "저장할 위치를 선택하세요."  // 안내 메시지
        );

        // 사용자가 취소했을 경우
        if (string.IsNullOrEmpty(path))
        {
            Debug.LogWarning("파일 저장이 취소되었습니다.");
            return;
        }

        // 새 ScriptableObject 생성
        grassDataList = ScriptableObject.CreateInstance<GrassDataList>();
        AssetDatabase.CreateAsset(grassDataList, path);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log($"잔디 데이터가 저장되었습니다: {path}");
    }

    private void LoadGrassData()
    {
        string path = EditorUtility.OpenFilePanel("Load Grass Data", Application.dataPath, "asset");

        if (string.IsNullOrEmpty(path))
        {
            Debug.LogWarning("파일 불러오기가 취소되었습니다.");
            return;
        }

        if (!path.StartsWith(Application.dataPath))
        {
            Debug.LogError("선택한 파일이 프로젝트 내부에 없습니다.");
            return;
        }

        string relativePath = "Assets" + path.Substring(Application.dataPath.Length);
        GrassDataList loadedData = AssetDatabase.LoadAssetAtPath<GrassDataList>(relativePath);

        if (loadedData == null)
        {
            Debug.LogError("선택한 파일이 유효한 GrassDataList.asset이 아닙니다.");
            return;
        }

        Debug.Log($"GrassDataList 불러오기 완료: {relativePath}");

        grassDataList = loadedData;
        grassSavePath = loadedData.lastSavedPath;

        // 프리팹 목록에 추가
        RegisterLoadedPrefabs();

        // 데이터를 반영
        HY_GrassDetailRenderer renderer = FindObjectOfType<HY_GrassDetailRenderer>();
        if (renderer != null)
        {
            renderer.SetGrassData(grassDataList);
            Debug.Log("HY_GrassDetailRenderer에 새로운 데이터 적용 완료!");
        }
        else
        {
            Debug.LogWarning("HY_GrassDetailRenderer가 씬에 없습니다!");
        }
    }

    private void RegisterLoadedPrefabs()
    {
        if (grassDataList == null || grassDataList.grassTypes == null)
            return;

        foreach (var grassType in grassDataList.grassTypes)
        {
            // 중복 방지
            if (!grassPrefabs.Contains(grassType.prefab))
            {
                grassPrefabs.Add(grassType.prefab);
            }
        }
    }

    private void ClearGrass()
    {
        if (grassDataList != null)
        {
            bool confirm = EditorUtility.DisplayDialog(
                "초기화 확인",
                "모든 잔디 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
                "확인",
                "취소"
            );

            if (confirm)
            {
                grassDataList.grassTypes.Clear();
                grassDataList.zones.Clear(); // 존 인스턴스도 함께 초기화
                grassDataList.lastSavedPath = "Assets";

                EditorUtility.SetDirty(grassDataList);
                Debug.Log("모든 잔디 데이터 초기화 완료.");
            }
            else
            {
                Debug.Log("초기화 작업이 취소되었습니다.");
            }
        }
    }

    private static string GetFolderOfThisScript()
    {
        string[] guids = AssetDatabase.FindAssets("t:Folder");

        foreach (var guid in guids)
        {
            string folderPath = AssetDatabase.GUIDToAssetPath(guid);
            if (folderPath.EndsWith("HY_GrassDetailTool"))
            {
                return folderPath;
            }
        }

        Debug.LogWarning("HY_GrassDetailTool 폴더를 찾지 못했습니다. 기본 Assets 경로를 사용합니다.");
        return "Assets";
    }



    public static Mesh CreateCrossMesh(float width = 1f, float height = 1f)
    {
        Mesh mesh = new Mesh();

        Vector3[] vertices = new Vector3[8];
        Vector2[] uvs = new Vector2[8];
        int[] triangles = new int[12];

        // 크로스 형태의 2장 쿼드
        float hw = width * 0.5f;
        float hh = height;

        // 수직 쿼드
        vertices[0] = new Vector3(-hw, 0, 0);
        vertices[1] = new Vector3(hw, 0, 0);
        vertices[2] = new Vector3(hw, hh, 0);
        vertices[3] = new Vector3(-hw, hh, 0);

        // 수평 쿼드 (Z축 기준으로 회전한 형태)
        vertices[4] = new Vector3(0, 0, -hw);
        vertices[5] = new Vector3(0, 0, hw);
        vertices[6] = new Vector3(0, hh, hw);
        vertices[7] = new Vector3(0, hh, -hw);

        for (int i = 0; i < 8; i++)
            uvs[i] = new Vector2(i % 2, i / 2 % 2);

        triangles = new int[]
        {
        0, 2, 1, 0, 3, 2, // 수직
        4, 6, 5, 4, 7, 6  // 수평
        };

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();

        return mesh;
    }

    public static Material CreateGrassMaterial(Texture2D mainTex, string savePath, bool alphaClip = true)
    {
        Shader shader = Shader.Find("Universal Render Pipeline/Lit") ?? Shader.Find("Standard");
        string matName = mainTex.name + "_Material";
        string matPath = System.IO.Path.Combine(savePath, matName + ".asset").Replace("\\", "/");

        // 기존 매트리얼이 있으면 그거 사용
        Material existingMat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
        if (existingMat != null)
        {
            Debug.Log($"기존 매트리얼 사용됨: {matPath}");
            return existingMat;
        }

        // 새로 생성
        Material mat = new Material(shader);
        mat.mainTexture = mainTex;

        if (shader.name == "Universal Render Pipeline/Lit")
        {
            mat.SetFloat("_Surface", 0);
            mat.SetFloat("_AlphaClip", alphaClip ? 1 : 0);
            mat.SetFloat("_Cull", 0);
            mat.EnableKeyword("_ALPHATEST_ON");
        }
        else if (shader.name == "Standard")
        {
            mat.SetFloat("_Mode", 1);
            mat.EnableKeyword("_ALPHATEST_ON");
            mat.renderQueue = 2450;
        }
        mat.enableInstancing = true;

        AssetDatabase.CreateAsset(mat, matPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        return mat;
    }


    public static T SaveAsset<T>(T asset, string path, string name) where T : Object
    {
        if (!AssetDatabase.IsValidFolder(path))
        {
            Debug.Log($"폴더 생성: {path}");
            AssetDatabase.CreateFolder("Assets", path.Replace("Assets/", ""));
        }

        string filePath = System.IO.Path.Combine(path, name + ".asset");
        filePath = AssetDatabase.GenerateUniqueAssetPath(filePath);

        AssetDatabase.CreateAsset(asset, filePath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        return AssetDatabase.LoadAssetAtPath<T>(filePath);
    }

    public static GameObject CreateGrassPrefab(string path, string name, Mesh mesh, Material mat)
    {
        if (mesh == null)
        {
            Debug.LogError("메쉬가 null입니다!"); return null;
        }

        if (mat == null)
        {
            Debug.LogError("머티리얼이 null입니다!"); return null;
        }

        // 경로 보정
        if (!AssetDatabase.IsValidFolder(path))
        {
            Debug.LogWarning($"경로가 없어 자동 생성합니다: {path}");
            AssetDatabase.CreateFolder("Assets", "GrassAuto");
            path = "Assets/GrassAuto";
        }

        string fullPath = System.IO.Path.Combine(path, name + ".prefab");
        fullPath = fullPath.Replace("\\", "/"); // Windows 경로 보정

        GameObject existingPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(fullPath);

        GameObject temp = new GameObject(name);
        var mf = temp.AddComponent<MeshFilter>();
        var mr = temp.AddComponent<MeshRenderer>();
        mf.sharedMesh = mesh;
        mr.sharedMaterial = mat;

        GameObject prefab;

        if (existingPrefab != null)
        {
            // 덮어쓰기
            PrefabUtility.SaveAsPrefabAssetAndConnect(temp, fullPath, InteractionMode.AutomatedAction);
            prefab = AssetDatabase.LoadAssetAtPath<GameObject>(fullPath);
            Debug.Log($"기존 프리팹 덮어쓰기 완료: {fullPath}");
        }
        else
        {
            // 새로 생성
            fullPath = AssetDatabase.GenerateUniqueAssetPath(fullPath);
            PrefabUtility.SaveAsPrefabAsset(temp, fullPath);
            prefab = AssetDatabase.LoadAssetAtPath<GameObject>(fullPath);
            Debug.Log($"새 프리팹 생성 완료: {fullPath}");
        }

        GameObject.DestroyImmediate(temp);

        return prefab;
    }

    public static Mesh CreateSinglePlaneMesh(float width = 1f, float height = 1f)
    {
        Mesh mesh = new Mesh();

        float hw = width * 0.5f;
        Vector3[] vertices = new Vector3[]
        {
        new Vector3(-hw, 0, 0),
        new Vector3(hw, 0, 0),
        new Vector3(hw, height, 0),
        new Vector3(-hw, height, 0)
        };

        int[] triangles = new int[]
        {
        0, 2, 1,
        0, 3, 2
        };

        Vector2[] uvs = new Vector2[]
        {
        new Vector2(0,0),
        new Vector2(1,0),
        new Vector2(1,1),
        new Vector2(0,1)
        };

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();

        return mesh;
    }

}

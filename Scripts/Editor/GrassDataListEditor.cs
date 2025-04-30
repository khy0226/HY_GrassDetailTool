using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

[CustomEditor(typeof(GrassDataList))]
public class GrassDataListEditor : Editor
{
    private Dictionary<int, bool> zoneFoldout = new Dictionary<int, bool>();
    private Dictionary<int, bool> prefabFoldout = new Dictionary<int, bool>();

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

        GUILayout.Space(15);
        GUILayout.Label("프리팹 설정", EditorStyles.boldLabel);

        for (int i = 0; i < data.grassTypes.Count; i++)
        {
            var typeData = data.grassTypes[i];
            bool foldout = EditorGUILayout.Foldout(true, $"프리팹 {i}: {typeData.prefab?.name ?? "Unnamed"}", true);
            if (!foldout) continue;

            EditorGUI.indentLevel++;

            var originalPrefab = typeData.prefab;
            var newPrefab = (GameObject)EditorGUILayout.ObjectField("Prefab", typeData.prefab, typeof(GameObject), false);

            if (originalPrefab != newPrefab)
            {
                pendingNewPrefab = newPrefab;
                pendingTargetTypeData = typeData;
                typeData.prefab = originalPrefab;
            }

            PrefabChange(data, typeData);

            EditorGUI.BeginChangeCheck();

            typeData.hasShadow = EditorGUILayout.Toggle("그림자 사용", typeData.hasShadow);
            if (EditorGUI.EndChangeCheck())
            {
                typeData.isShadowManuallyOverridden = true;
            }

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
            bool fold = EditorGUILayout.Foldout(true, $"Zone {i} - {zone.zoneName} ({zone.instanceGroups.Count} 프리팹)", true);
            if (!fold) continue;

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
            EditorGUILayout.LabelField(
                "프리팹이 변경되었습니다.\n잔디 인스턴스에 새 프리팹을 적용할까요?",
                EditorStyles.wordWrappedLabel
            );
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("교체하기"))
            {
                ApplyPrefabReplacement(data, pendingTargetTypeData, pendingNewPrefab);
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
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.EndVertical();
        }
    }

    private void ApplyPrefabReplacement(GrassDataList data, GrassTypeData oldType, GameObject newPrefab)
    {
        GameObject oldPrefab = oldType.prefab;

        oldType.prefab = newPrefab;
        oldType.LoadLODFromPrefab(); // 새 프리팹에 맞춰 LOD 다시 로드

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

}

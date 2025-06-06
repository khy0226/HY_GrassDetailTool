using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[Serializable]
public class LODRenderElement
{
    public Mesh mesh;
    public Material material;
    public int subMeshIndex;
}

[Serializable]
public class LODLevel
{
    public List<LODRenderElement> renderers = new List<LODRenderElement>();

    [Range(0f, 1f)]
    public float transitionDistance = 0.5f; // 이게 LOD 전환용 거리 기준
}

[Serializable]
public class GrassTypeData
{
    public GameObject prefab;
    public bool hasShadow = true;

    public List<LODLevel> lodLevels = new List<LODLevel>();

    public void LoadLODFromPrefab(bool preserveTransition = true)
    {
        if (prefab == null)
        {
            lodLevels = new List<LODLevel>();
            return;
        }

        List<float> oldDistances = lodLevels.Select(l => l.transitionDistance).ToList();
        lodLevels = new List<LODLevel>();

        LODGroup lodGroup = prefab.GetComponent<LODGroup>();
        if (lodGroup != null)
        {
            LOD[] lods = lodGroup.GetLODs();
            bool keepOldTransition = preserveTransition && oldDistances.Count == lods.Length;

            for (int i = 0; i < lods.Length; i++)
            {
                LODLevel level = new LODLevel();
                level.renderers = new List<LODRenderElement>();

                level.transitionDistance = keepOldTransition
                    ? oldDistances[i]
                    : (i < lods.Length - 1 ? (i + 1f) / lods.Length : 1f);

                foreach (Renderer renderer in lods[i].renderers)
                {
                    MeshFilter mf = renderer.GetComponent<MeshFilter>();
                    if (mf == null || mf.sharedMesh == null) continue;

                    Mesh mesh = mf.sharedMesh;
                    var materials = renderer.sharedMaterials;
                    int subMeshCount = mesh.subMeshCount;

                    for (int m = 0; m < Mathf.Min(subMeshCount, materials.Length); m++)
                    {
                        var mat = materials[m];
                        if (mat == null) continue;

                        level.renderers.Add(new LODRenderElement {
                            mesh = mesh,
                            material = mat,
                            subMeshIndex = m
                        });
                    }
                }

                lodLevels.Add(level);
            }
        }
        else
        {
            Renderer renderer = prefab.GetComponentInChildren<Renderer>();
            if (renderer != null)
            {
                MeshFilter mf = renderer.GetComponent<MeshFilter>();
                if (mf != null && mf.sharedMesh != null)
                {
                    LODLevel level = new LODLevel {
                        transitionDistance = 1f,
                        renderers = new List<LODRenderElement>
                        {
                        new LODRenderElement
                        {
                            mesh = mf.sharedMesh,
                            material = renderer.sharedMaterial
                        }
                    }
                    };
                    lodLevels.Add(level);
                }
            }
        }
            hasShadow = DetectShadowFromPrefab(prefab);
    }


    public bool DetectShadowFromPrefab(GameObject prefab)
    {
        LODGroup lodGroup = prefab.GetComponent<LODGroup>();

        if (lodGroup != null)
        {
            var lods = lodGroup.GetLODs();
            if (lods.Length > 0 && lods[0].renderers.Length > 0)
            {
                var renderers = lods[0].renderers;
                bool? common = null;

                foreach (var rend in renderers)
                {
                    if (rend == null) continue;
                    var current = rend.shadowCastingMode != UnityEngine.Rendering.ShadowCastingMode.Off;

                    if (common == null)
                        common = current;
                    else if (common != current)
                        return true; // 일치하지 않음 → 일단 '사용'으로 처리
                }

                return common ?? true;
            }
        }
        else
        {
            // LODGroup이 없을 때는 모든 렌더러들의 설정 확인
            var renderers = prefab.GetComponentsInChildren<Renderer>();
            bool? common = null;

            foreach (var rend in renderers)
            {
                if (rend == null) continue;
                var current = rend.shadowCastingMode != UnityEngine.Rendering.ShadowCastingMode.Off;

                if (common == null)
                    common = current;
                else if (common != current)
                    return true; // 불일치 → 사용
            }

            return common ?? true;
        }

        return true;
    }

}

[CreateAssetMenu(fileName = "GrassDataList", menuName = "HY/Grass Data List")]
public class GrassDataList : ScriptableObject
{
    [Header("프리팹 데이터 목록")]
    public List<GrassTypeData> grassTypes = new List<GrassTypeData>();

    [Header("존별 인스턴스 데이터")]
    public List<GrassZone> zones = new List<GrassZone>();
    public bool useZones = false;

    [Header("전체 지도 크기 (X: 너비, Y: 높이)")]
    public Vector2 mapSize = new Vector2(2048, 2048);

    [Header("몇 등분할지 설정 (가로, 세로)")]
    public int divisionCountX = 1;
    public int divisionCountY = 1;

    [Header("공통 설정")]
    public float maxCullDistance = 100f; // 전역 최대 거리
    public bool useGlobalLOD = true;

    public enum RenderMode { DrawMeshInstanced, DrawMeshInstancedIndirect };
    [Header("렌더링 방식 설정")]
    public RenderMode renderMode = RenderMode.DrawMeshInstanced;

    [HideInInspector]
    public string lastSavedPath = "Assets";

    public bool AddToZoneInstanceGroup(string zoneName, GameObject prefab, GrassData newData)
    {
        // 대상 존 찾기 또는 생성
        GrassZone zone = zones.FirstOrDefault(z => z.zoneName == zoneName);
        if (zone == null)
        {
            zone = new GrassZone {
                zoneName = zoneName,
                zoneCenter = Vector2.zero, // 초기화 후 추후 계산
                zoneSize = Mathf.Max(mapSize.x / divisionCountX, mapSize.y / divisionCountY),
                instanceGroups = new List<GrassZoneInstanceGroup>()
            };
            zones.Add(zone);
        }

        // 해당 프리팹 그룹 찾기 또는 생성
        GrassZoneInstanceGroup group = zone.instanceGroups.FirstOrDefault(g => g.prefab == prefab);
        if (group == null)
        {
            group = new GrassZoneInstanceGroup { prefab = prefab };
            zone.instanceGroups.Add(group);
        }

        group.instances.Add(newData);

        return false;
    }

}


[Serializable]
public class GrassZone
{
    public string zoneName;
    public Vector2 zoneCenter;      // 중심 좌표
    public float zoneSize;          // 반지름 또는 사이즈
    public Bounds bounds;

    // 이 존 안에 심어진 프리팹별 인스턴스 정보
    public List<GrassZoneInstanceGroup> instanceGroups = new List<GrassZoneInstanceGroup>();

}

[Serializable]
public class GrassZoneInstanceGroup
{
    public GameObject prefab;       // 어떤 프리팹인지
    public List<GrassData> instances = new List<GrassData>();
}

[Serializable]
public class GrassData
{
    public Vector3 position;
    public Quaternion rotation;
    public Vector3 scale;
    public int prefabIndex;

}
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(HY_GrassDetailRenderer))]
public class HY_GrassDetailRendererEditor : Editor
{
    private Editor grassDataListEditor; // `GrassDataList`의 인스펙터를 표시하기 위한 Editor 인스턴스
    private bool showGrassDataList = true; // 접기/펼치기 상태 저장

    public override void OnInspectorGUI()
    {
        HY_GrassDetailRenderer renderer = (HY_GrassDetailRenderer)target;

        // 기존 인스펙터 UI 유지
        DrawDefaultInspector();

        GUILayout.Space(10);
        GUILayout.Label("잔디 데이터 설정", EditorStyles.boldLabel);

        if (renderer.grassDataList != null)
        {
            // 접기/펼치기 버튼 추가
            showGrassDataList = EditorGUILayout.Foldout(showGrassDataList, "Grass Data List 설정 보기", true);

            if (showGrassDataList)
            {
                EditorGUILayout.BeginVertical("box");

                // `GrassDataList` 인스펙터 UI를 렌더러 인스펙터에서 그대로 표시
                if (grassDataListEditor == null || grassDataListEditor.target != renderer.grassDataList)
                {
                    grassDataListEditor = CreateEditor(renderer.grassDataList);
                }
                grassDataListEditor.OnInspectorGUI();

                EditorGUILayout.EndVertical();
            }
        }
        else
        {
            EditorGUILayout.HelpBox("GrassDataList가 없습니다! 잔디 데이터를 설정해주세요.", MessageType.Warning);
        }
    }
}

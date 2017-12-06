using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace FenceWizard
{
    public class FenceWizard : EditorWindow
    {

        public GameObject fence;
        public bool continuous;
        public float extraHeight;
        public float extraLength;
        public float additionalOffset;

        [MenuItem("Tools/FenceAndPathway/FenceWizard")]
        public static void Init()
        {
            var window = EditorWindow.GetWindow<FenceWizard>();
            window.Show();
        }

        void OnGUI()
        {
            fence = (GameObject)EditorGUILayout.ObjectField(fence, typeof(GameObject));

            EditorGUILayout.LabelField("Continuous");

            continuous = EditorGUILayout.Toggle(continuous);

            EditorGUILayout.LabelField("Extra Height");

            extraHeight = EditorGUILayout.Slider(extraHeight, -10, 10);

            EditorGUILayout.LabelField("Additional Vertical Offset");

            additionalOffset = EditorGUILayout.FloatField(additionalOffset);

            if (continuous)
            {
                EditorGUILayout.LabelField("Extra Length");
                extraLength = EditorGUILayout.Slider(extraLength, 0, 10);
            }

            var col = GUI.color;

            if (!FindObjectOfType<Fence>())
            {
                GUI.color = Color.green;

                if (fence && GUILayout.Button("Begin Editing"))
                {
                    GameObject g = new GameObject();
                    g.AddComponent<Fence>().continuous = continuous;
                    Selection.activeGameObject = g;
                    SceneView.RepaintAll();
                    g.name = "Temporary Fence Wizard Helper";
                }
            }
            else
            {
                var f = FindObjectOfType<Fence>();
                f.prefab = this.fence;
                f.continuous = continuous;
                f.extraHeight = extraHeight;
                f.extraLength = extraLength;
                f.additionalOffset = additionalOffset;

                GUI.color = Color.red;
                if (GUILayout.Button("End Editing"))
                {
                    DestroyImmediate(f.gameObject);
                }
            }
            GUI.color = col;
        }

        void OnDisable()
        {
            if (FindObjectOfType<Fence>())
            {
                FindObjectOfType<Fence>().ClearFences();
                DestroyImmediate(FindObjectOfType<Fence>().gameObject);
            }
        }
    }
}
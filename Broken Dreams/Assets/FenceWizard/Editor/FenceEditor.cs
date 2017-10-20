using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace FenceWizard
{
    [CustomEditor(typeof(Fence))]
    public class FenceEditor : Editor
    {

        void OnSceneGUI()
        {
            var fence = (Fence)target;
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Keyboard));

            Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit))
            {
                Handles.DrawWireDisc(hit.point, hit.normal, 0.25f);
                fence.SetLastMousePosition(hit.point);
            }

            if (Event.current.type == EventType.MouseDown)
            {
                if (Event.current.button == 0)
                {
                    fence.AddFence(hit.point);
                }
            }

            if (Event.current.type == EventType.MouseUp)
            {
                if (Event.current.button == 0)
                {
                    fence.ClearFences();
                }
            }
            SceneView.RepaintAll();
        }
    }
}
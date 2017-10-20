using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace FenceWizard
{
    [ExecuteInEditMode]
    public class Fence : MonoBehaviour
    {

        List<GameObject> cachedFence = new List<GameObject>();
        private Vector3 lastMousepos;
        private float size;
        public float extraHeight = 0;
        public float extraLength = 0;
        public float additionalOffset = 0;

        public bool continuous;

        public GameObject prefab;

        public void AddFence(Vector3 pos)
        {
            GameObject p = GameObject.Instantiate(prefab, null);
            prefab.transform.position = Vector3.zero;
            //prefab.transform.rotation = Quaternion.identity;
            Undo.RegisterCreatedObjectUndo(p, "Add Fence " + p.name);
            MeshRenderer renderer = p.GetComponentInChildren<MeshRenderer>();
            GameObject anchor = new GameObject();
            anchor.transform.position = Vector3.zero;
            // decide which side to set the pivot anchor to
            if (renderer.bounds.size.x > renderer.bounds.size.z)
            {
                anchor.transform.position = new Vector3(renderer.bounds.min.x, renderer.bounds.min.y, p.transform.position.z);
                size = renderer.bounds.size.x;

                anchor.transform.LookAt(p.transform);
                p.transform.SetParent(anchor.transform);

                anchor.transform.position = pos + new Vector3(0, additionalOffset, 0);

                SetChildColliders(anchor, false);

                cachedFence.Add(anchor);
            }
            else
            {
                if (renderer.bounds.size.z > renderer.bounds.size.x)
                {
                    anchor.transform.position = new Vector3(p.transform.position.z, renderer.bounds.min.y, renderer.bounds.min.x);
                    size = renderer.bounds.size.z;

                    anchor.transform.LookAt(p.transform);
                    p.transform.SetParent(anchor.transform);

                    anchor.transform.position = pos + new Vector3(0, additionalOffset, 0);

                    SetChildColliders(anchor, false);

                    cachedFence.Add(anchor);
                }
            }
        }

        public void ClearFences()
        {
            for (int i = 0; i < cachedFence.Count; i++)
            {
                SetChildColliders(cachedFence[i].transform.gameObject, true);
                cachedFence[i].transform.GetChild(0).parent = null;
                DestroyImmediate(cachedFence[i].gameObject);
            }
            cachedFence.Clear();
        }

        void SetChildColliders(GameObject g, bool enabled)
        {
            Collider[] colliders = g.GetComponentsInChildren<Collider>();

            for (int i = 0; i < colliders.Length; i++)
            {
                colliders[i].enabled = enabled;
            }
        }

        public void SetLastMousePosition(Vector3 pos)
        {
            lastMousepos = pos;
        }

        void OnDisable()
        {
            ClearFences();
        }

        void OnDrawGizmos()
        {
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Keyboard));

            Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit))
            {
                SetLastMousePosition(hit.point);
            }
            SceneView.RepaintAll();
            Selection.activeGameObject = gameObject;
            for (int i = 0; i < cachedFence.Count; i++)
            {
                cachedFence[i].transform.LookAt(lastMousepos + new Vector3(0, extraHeight, 0));
                if (continuous)
                {
                    if (Mathf.Abs(Vector3.Distance(cachedFence[i].transform.position, hit.point)) > size + extraLength)
                    {
                        ClearFences();
                        AddFence(hit.point);
                    }
                }
            }
        }
    }
}
using UnityEngine;
using System.Collections;

public class SpawnGroup : MonoBehaviour
{

    public Transform[] spawnpoints;
    public bool autoAssignspawnpoints = true;

    void Awake()
    {
        if (autoAssignspawnpoints)
        {
            Transform[] temp = new Transform[gameObject.GetComponentsInChildren<Transform>().Length - 1];
            spawnpoints.CopyTo(temp, 0);
            spawnpoints = temp;
            for (int i = 0; i < gameObject.GetComponentsInChildren<Transform>().Length; i++)
            {
                spawnpoints[i] = gameObject.GetComponentsInChildren<Transform>()[i];
            }
        }
    }

    public int getLength()
    {
        return spawnpoints.Length;
    }
}

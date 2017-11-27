using UnityEngine;
using System.Collections;

public class WaypointGroup : MonoBehaviour {

    public Transform[] waypoints;
    public bool autoAssignWaypoints = true;

    void Awake()
    {
        if (autoAssignWaypoints)
        {
            Transform[] temp = new Transform[gameObject.GetComponentsInChildren<Transform>().Length - 1];
            waypoints.CopyTo(temp, 0);
            waypoints = temp; 
            for (int i = 0; i<gameObject.GetComponentsInChildren<Transform>().Length;i++)
            {
                waypoints[i] = gameObject.GetComponentsInChildren<Transform>()[i];
            }
        }
    }

    public int getLength()
    {
        return waypoints.Length;
    }
}

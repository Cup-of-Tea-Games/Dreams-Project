using UnityEngine;
using System.Collections;

public class Room : MonoBehaviour {

    public WaypointGroup waypoints;
    public Collider area;

    bool colliding;
    GameObject Player;

    void Awake()
    {
        Player = GameObject.Find("Player");
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.gameObject == Player)
        {
            colliding = true;
            Debug.Log("PLAYER IS HERE");
        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.gameObject == Player)
        {
            colliding = false;
            Debug.Log("PLAYER IS NOT HERE");
        }
    }

    public bool isColliding()
    {
        return colliding;
    }
}

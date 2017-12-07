using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColliderDetector : MonoBehaviour {

    bool colliding;
    public string tagName;

    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == tagName)
        {
            colliding = true;
        }
    }

    void OnCollisionExit(Collision col)
    {
        if (col.gameObject.tag == tagName)
        {
            colliding = false;
        }
    }

    public bool isColliding()
    {
        return colliding;
    }
}

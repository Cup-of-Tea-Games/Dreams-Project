using UnityEngine;
using System.Collections;

public class IgnoreCollision : MonoBehaviour {

    public string ignoreTag;

    void OnCollisionEnter(Collision col)
    {
        if(col.gameObject.tag == ignoreTag)
        {
            Physics.IgnoreCollision(col.collider, GetComponent<Collider>());
        }
    }
}

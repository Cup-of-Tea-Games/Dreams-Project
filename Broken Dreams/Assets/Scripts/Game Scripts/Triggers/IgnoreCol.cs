using UnityEngine;
using System.Collections;

public class IgnoreCol : MonoBehaviour {

    public string ignoreExceptTag;

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag != ignoreExceptTag)
        {
            Physics.IgnoreCollision(collision.collider, GetComponent<Collider>());
        }
        
    }

  }

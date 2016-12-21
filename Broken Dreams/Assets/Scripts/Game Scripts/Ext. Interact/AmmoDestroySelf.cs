using UnityEngine;
using System.Collections;

public class AmmoDestroySelf : MonoBehaviour {

    void OnTriggerEnter(Collider col)
    {
        if (col.tag == "Player")
        {
            Destroy(gameObject);
        }
    }
}

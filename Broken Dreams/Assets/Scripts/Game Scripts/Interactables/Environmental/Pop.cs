using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pop : MonoBehaviour {

    public Transform popDirection;
    public float popForce;
    public bool popOnAwake;
    public bool destroyOnPop = false;
    public float destroyTime;

    public void PopOut()
    {
        GetComponent<Rigidbody>().isKinematic = false;
        GetComponent<Rigidbody>().AddForce(popDirection.forward*popForce*100);
        if(destroyOnPop)
        Destroy(gameObject, destroyTime);
    }

    bool activate = true;

    void Update()
    {
        if (activate)
        {
            activate = false;
            PopOut();
        }
    }
}

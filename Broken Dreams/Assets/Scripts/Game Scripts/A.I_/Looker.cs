using UnityEngine;
using System.Collections;

public class Looker : MonoBehaviour {

    public Transform target;

    void Update()
    {
        transform.LookAt(target);
    }
}

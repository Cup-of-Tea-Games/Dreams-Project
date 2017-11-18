using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraAxis : MonoBehaviour {

    Transform originalTransform;
    public GameObject cam;

    // Use this for initialization
    void Awake()
    {

	}

    void Update()
    {
        cam.gameObject.transform.position = new Vector3(0,0,0);
    }
	
}

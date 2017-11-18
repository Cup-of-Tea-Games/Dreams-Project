using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateFollow : MonoBehaviour {

    public Transform target;
    public float smoothTime = 0f;
	void Update () {
        gameObject.transform.rotation = Quaternion.Lerp(gameObject.transform.rotation,target.transform.rotation,smoothTime*Time.deltaTime);
	}
}

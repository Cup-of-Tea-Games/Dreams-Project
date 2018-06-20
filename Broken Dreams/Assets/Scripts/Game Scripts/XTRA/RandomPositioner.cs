using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomPositioner : MonoBehaviour {

    public Transform[] positions;

	void Awake () {

        int x = Random.Range(0,positions.Length);

        GetComponent<Transform>().position = positions[x].position;
        GetComponent<Transform>().rotation = positions[x].rotation;

    }
	
}

using UnityEngine;
using System.Collections;

public class DisablePortal : MonoBehaviour {


void OnTriggerEnter (Collider other)

{
GameObject.Find("Portal System 1 (1)").SetActive(true);
}

void OnTriggerExit (Collider other)
{
GameObject.Find("Portal System 1 (1)").SetActive(false);
}

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}

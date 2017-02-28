using UnityEngine;
using System.Collections;

public class RestartLevel : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	 if (Input.GetKeyDown(KeyCode.L))
{
Application.LoadLevel ("Apartment");
}

	}
}

using UnityEngine;
using System.Collections;

public class MessengerScript : MonoBehaviour {

void OnTriggerEnter (Collider other)

{
GameObject.Find("ReceiverObject").GetComponent<RandomValueReceiver>().RandomReceiver++;
Debug.Log("MessageSent");
}

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}

using UnityEngine;
using System.Collections;

public class RandomValueReceiver : MonoBehaviour {
public int RandomReceiver = 0;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {

if (RandomReceiver == 1)
{
Debug.Log("1");
}
else if (RandomReceiver ==2)
{
Debug.Log("2");
}
else if (RandomReceiver == 3)
{
Debug.Log("3");
}
	}
}

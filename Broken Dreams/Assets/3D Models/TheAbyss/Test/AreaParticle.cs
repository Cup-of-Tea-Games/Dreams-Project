using UnityEngine;
using System.Collections;

public class AreaParticle : MonoBehaviour {

public ParticleSystem AreaParticles;

void Awake ()
{
AreaParticles.Stop();
Debug.Log("Stopped");
}


void OnTriggerEnter ()
{
AreaParticles.Play();
Debug.Log("Entered");
}

void OnTriggerExit ()
{
AreaParticles.Stop();
Debug.Log ("Exit");
}


	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}


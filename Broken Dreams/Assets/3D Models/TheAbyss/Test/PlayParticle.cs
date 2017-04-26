using UnityEngine;
using System.Collections;

public class PlayParticle : MonoBehaviour {
public ParticleSystem ParticleTest;
public bool Triggered = false;

void Awake() 
{
ParticleTest.Stop();
}

void OnTriggerEnter (Collider other)
{

if(Triggered == false)
{
ParticleTest.Play();
Triggered = true;
}


}

void OnTriggerExit (Collider other)
{

ParticleTest.Stop();
}


}

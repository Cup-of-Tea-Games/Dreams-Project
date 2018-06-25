using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonsterProximityTrigger : MonoBehaviour {

    public List<Monster> monsters;

    public bool includePerlinNoise = false;
    public PerlinNoise perlinNoise;
    private float originalShakeAmount;
    public MusicMixer mixer;

	// Use this for initialization
	void Awake ()
    {

      //  foreach (GameObject monster in FindObjectsOfType(typeof(Monster)) as GameObject[])
     //   {
     //       monsters.Add(monster.GetComponent<Monster>());
    //        Debug.Log("MONSTERS ADDED");
     //   }

        if (perlinNoise != null)
            originalShakeAmount = perlinNoise.shakeAmount;

    }
	
	// Update is called once per frame
	void Update () {


        if (MusicMixer.enemiesChasing != 0)
        {
            perlinNoise.enabled = true;
            for (int i = 0; i < monsters.Count; i++)
            {
                float distance = Vector3.Distance(transform.position, monsters[i].transform.position);

                if (includePerlinNoise)
                {
                    if (distance <= 5)
                    {
                        perlinNoise.enabled = true;
                        perlinNoise.shakeAmount = originalShakeAmount;
                    }
                    else if (distance <= 4)
                    {
                        perlinNoise.enabled = true;
                        perlinNoise.shakeAmount = originalShakeAmount * 1.1f;
                        mixer.GetComponent<AudioSource>().volume = 0.7f;
                    }
                    else if (distance <= 3)
                    {
                        perlinNoise.enabled = true;
                        perlinNoise.shakeAmount = originalShakeAmount * 1.2f;
                        mixer.GetComponent<AudioSource>().volume = 0.9f;
                    }
                    else if (distance <= 2)
                    {
                        perlinNoise.enabled = true;
                        perlinNoise.shakeAmount = originalShakeAmount * 2f;
                        mixer.GetComponent<AudioSource>().volume = 1.0f;
                    }
                    else if (distance <= 1)
                    {
                        perlinNoise.enabled = true;
                        perlinNoise.shakeAmount = originalShakeAmount * 3f;
                        mixer.GetComponent<AudioSource>().volume = 1.2f;
                    }
                }


            }
        }
        else
        {
            perlinNoise.enabled = false;
            mixer.GetComponent<AudioSource>().volume = 0.5f;
        }
		
	}
}

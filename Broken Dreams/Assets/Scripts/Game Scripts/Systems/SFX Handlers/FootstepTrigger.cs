using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Characters.FirstPerson;

public class FootstepTrigger : MonoBehaviour {

    public bool isPlayer = false;
    public bool playSFX = false;
    public AudioSource footStepSource;
    public AudioClip[] clips;

   void Update()
    {
        if (playSFX)
        {
            int x = Random.Range(0, clips.Length);
            if (isPlayer)
            {
                footStepSource.GetComponent<FirstPersonController>().PlayFootStepAudio();
            }
          //  footStepSource.PlayOneShot(clips[x]);
            playSFX = false;
        }
    }
    
}

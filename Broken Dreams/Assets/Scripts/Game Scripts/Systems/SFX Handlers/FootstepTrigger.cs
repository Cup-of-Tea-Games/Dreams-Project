using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Characters.FirstPerson;

public class FootstepTrigger : MonoBehaviour {

    public FirstPersonController FPSController;
    public bool playSFX = false;

   void Update()
    {
        if (playSFX)
        {
            FPSController.PlayFootStepAudio();
            playSFX = false;
        }
    }
    
}

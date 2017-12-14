using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Utility;

public class Extractor : MonoBehaviour {

    public FollowTarget playerPos;
    bool playerInPos = false;
    Animator anim;
    public ExtractionMachine machine;

    void Awake()
    {
        anim = GetComponent<Animator>();
    }

    void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.tag == "Player")
        {
            playerInPos = true;
            playerPos.enabled = true;
            machine.doorA.close();
            machine.doorB.close();
            anim.Play("Extract");
        }
    }
}

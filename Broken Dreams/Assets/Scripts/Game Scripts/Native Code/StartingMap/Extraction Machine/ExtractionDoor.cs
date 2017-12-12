using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExtractionDoor : MonoBehaviour {

    Animator anim;

    void Awake()
    {
        anim = GetComponent<Animator>();
    }

    public void open()
    {
        anim.Play("Open");
    }

    public void close()
    {
        anim.Play("Close");
    }
}

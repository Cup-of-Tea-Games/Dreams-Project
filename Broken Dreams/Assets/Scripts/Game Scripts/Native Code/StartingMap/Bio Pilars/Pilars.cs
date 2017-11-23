using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pilars : MonoBehaviour {

    public Animator anim;

    public void rise()
    {
        anim.Play("Pilars Rise");
    }
}

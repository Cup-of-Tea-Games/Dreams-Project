using UnityEngine;
using System.Collections;

public class Unarmed : MonoBehaviour {

    //Animation
    public Animator animator;

    public void tossItem()
    {
        animator.Play("Toss");
    }

    void Reload()
    {
        animator.Play("");
    }
}

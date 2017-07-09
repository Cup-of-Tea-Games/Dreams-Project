using UnityEngine;
using System.Collections;

public class Lever : MonoBehaviour {

    public Animator animator;
    public Collider col;
    bool active = false;
    bool key1 = true;

    public void activate()
    {
        animator.Play("Pull");
        col.enabled = false;
        active = true;
    }

    public bool isActivated()
    {
        return active;
    }
}

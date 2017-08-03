using UnityEngine;
using System.Collections;

public class HyperDoor : MonoBehaviour {

    public Button button;
    public Animator animator;
    bool isClosed = true;

    void Update()
    {
        if (button.active)
        {
            if (!isClosed)
            {
                animator.Play("Open");
                isClosed = true;
            }
        }
        else
        {
            if (isClosed)
            {
                animator.Play("Close");
                isClosed = false;
            }
        }
    }
}

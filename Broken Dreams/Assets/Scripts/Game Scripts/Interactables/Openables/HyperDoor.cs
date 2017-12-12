using UnityEngine;
using System.Collections;

public class HyperDoor : MonoBehaviour {

    public Button button1;
    public Button button2;
    public Animator animator;
    bool isClosed = true;
    public bool initialState = false;
    bool buttonState = false;

    void Awake()
    {
        if (initialState)
        {
            animator.Play("Open");
            button1.active = true;
            isClosed = false;
        }
    }

    void Update()
    {
        bool buttonPressed = button1.active;

        button2.active = button1.active;

        if (buttonPressed)
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

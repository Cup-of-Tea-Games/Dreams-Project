using UnityEngine;
using System.Collections;

public class HyperDoor : MonoBehaviour {

    public Button button1;
    public Button button2;
    public Animator animator;
    bool isClosed = true;
    public bool initialState = false;
    bool buttonState = false;
    private AudioSource source;

    void Awake()
    {
        source = GetComponent<AudioSource>();

        StartCoroutine(muteAwake(3));

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
                source.pitch = 1.5f;
                source.Play();

                animator.Play("Open");
                isClosed = true;
            }
        }
        else
        {
            if (isClosed)
            {
                source.pitch = 1.2f;
                source.Play();

                animator.Play("Close");
                isClosed = false;
            }
        }
    }

    private IEnumerator muteAwake(int x)
    {
        source.mute = true;
        yield return new WaitForSeconds(x);
        source.mute = false;
        StopCoroutine(muteAwake(x));
    }
}

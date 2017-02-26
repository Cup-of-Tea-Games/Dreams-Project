using UnityEngine;
using System.Collections;

public class PCSFX : MonoBehaviour
{

    AudioSource audio;
    public AudioClip mouseClick;

    void Awake()
    {
        audio = GetComponent<AudioSource>();
        audio.clip = mouseClick;
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            audio.clip = mouseClick;
            audio.Play();
        }
    }

}

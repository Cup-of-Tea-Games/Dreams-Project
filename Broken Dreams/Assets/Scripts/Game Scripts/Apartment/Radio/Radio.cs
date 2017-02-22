using UnityEngine;
using System.Collections;

public class Radio : MonoBehaviour
{

    public AudioClip[] clips;
    public AudioSource Speaker;
    int currentClipCount = 0;
    public static bool isPlaying = false;

    void OnEnable()
    {
        isPlaying = true;
    }

    void OnDisable()
    {
        isPlaying = false;
    }

    void Awake()
    {
        ChangeClip();
        Speaker.clip = clips[currentClipCount];
        Speaker.Play();
    }

    void Update()
    {
        if (currentClipCount <= clips.Length)
        {
            if (Speaker.isPlaying == false)
            {
                ChangeClip();
                Speaker.clip = clips[currentClipCount];
                Speaker.Play();
            }
        }
    }

    void ChangeClip()
    {
        Speaker.Stop();
        int nextClip = Random.RandomRange(0, clips.Length);
        if (currentClipCount != nextClip)
            currentClipCount = nextClip;
        else
            ChangeClip();
    }

}

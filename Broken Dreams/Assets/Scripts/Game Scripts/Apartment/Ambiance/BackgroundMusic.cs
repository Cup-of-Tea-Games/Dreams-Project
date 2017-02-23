using UnityEngine;
using System.Collections;

public class BackgroundMusic : MonoBehaviour
{

    public AudioClip[] clips;
    public AudioSource Speaker;
    int currentClipCount = 0;
    public static bool isPlaying = false;
    float originalValue;

    void Awake()
    {
        ChangeClip();
        Speaker.clip = clips[currentClipCount];
        Speaker.Play();
        originalValue = Speaker.volume;
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

        isPlaying = Speaker.isPlaying;

        if(Radio.isPlaying || Commercials.isPlaying)
        {
            Speaker.volume = 0;
        }
        else
        {
            StartCoroutine(setOriginal());
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

    IEnumerator setOriginal()
    {
        yield return new WaitForSeconds(1f);
        Speaker.volume = originalValue;
        StopCoroutine(setOriginal());
    }

}

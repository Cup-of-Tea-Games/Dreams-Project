using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomNoiseGenerator : MonoBehaviour {

    public AudioClip[] clips;
    private AudioSource source;

    void Awake()
    {
        source = GetComponent<AudioSource>();
    }

    void Update()
    {

        if (!source.isPlaying)
        {
            StartCoroutine(switchTrack());
        }

    }

    IEnumerator switchTrack()
    {
        int x = Random.RandomRange(0, clips.Length);

        yield return new WaitForSeconds(2);
        source.clip = clips[x];
        if (!source.isPlaying)
        {
            source.Play();
        }
        StopCoroutine(switchTrack());
    }

    bool isPlaying()
    {
        bool temp = false;

        for (int i = 0; i < clips.Length; i++)
        {
        
        }

        return temp;
    }

}

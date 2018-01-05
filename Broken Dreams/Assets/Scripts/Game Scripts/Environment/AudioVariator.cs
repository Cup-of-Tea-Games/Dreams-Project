using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioVariator : MonoBehaviour {

    AudioSource source;

	// Use this for initialization
	void Start () {
        source = GetComponent<AudioSource>();
        int pitchNumber = 5;
        pitchNumber = Random.Range(0,5);
        switch (pitchNumber)
        {
            case 0:
                source.pitch = 0.8f;
            break;

            case 1:
                source.pitch = 0.9f;
                break;

            case 2:
                source.pitch = 1.0f;
                break;

            case 3:
                source.pitch = 1.1f;
                break;

            case 4:
                source.pitch = 1.2f;
                break;

            case 5:
                source.pitch = 1.3f;
                break;
        }

	}
	

}

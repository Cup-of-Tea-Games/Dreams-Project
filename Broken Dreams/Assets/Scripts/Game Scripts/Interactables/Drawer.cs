using UnityEngine;
using System.Collections;

public class Drawer : MonoBehaviour {

    public Transform originalPos;
    public Transform nextPos;
    public bool DoesItHaveSound;
    public AudioClip clip;
    bool toggle = false;
    AudioSource audio;
    public float pitchMultiplier = 1;

    void Awake()
    {
        if(DoesItHaveSound)
        {
            audio = GetComponent<AudioSource>();
            audio.clip = clip;
        }
    }

    void Update()
    {

        if (!toggle)
        {
            gameObject.transform.position = Vector3.Lerp(gameObject.transform.position, originalPos.position, 7 * Time.deltaTime);
        }
        else
        {
            gameObject.transform.position = Vector3.Lerp(gameObject.transform.position, nextPos.position, 7 * Time.deltaTime);
        }

    }
    public void move()
    {
        toggle = !toggle;

        if (DoesItHaveSound)
        {
            if (!toggle)
            {
                audio.pitch = 1.2f * pitchMultiplier;
                audio.Play();
            }
            else
            {
                audio.pitch = 1f * pitchMultiplier;
                audio.Play();
            }
        }
    }
}

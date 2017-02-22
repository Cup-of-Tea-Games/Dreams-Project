using UnityEngine;
using System.Collections;

public class Toggle : MonoBehaviour {

    bool togglebool = false;
    public GameObject toggleObject;
    AudioSource audio;

    void Awake()
    {
        audio = GetComponent<AudioSource>();
    }

	public void toggle()
    {
        togglebool = !togglebool;
        audio.Play();
        toggleObject.SetActive(togglebool);

    }
}

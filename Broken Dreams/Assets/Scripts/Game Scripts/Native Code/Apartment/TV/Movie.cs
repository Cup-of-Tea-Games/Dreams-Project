using UnityEngine;
using System.Collections;

public class Movie : MonoBehaviour
{
    public bool playOnAwake = false;
    public MovieTexture movTexture;
    void Start()
    {
        GetComponent<Renderer>().material.mainTexture = movTexture;
        if(playOnAwake)
        movTexture.Play();
    }

}

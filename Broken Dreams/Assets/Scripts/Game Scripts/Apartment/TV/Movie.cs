using UnityEngine;
using System.Collections;

public class Movie : MonoBehaviour
{

    private MovieTexture mtex;

    // Use this for initialization
    void Start()
    {
        mtex = gameObject.GetComponent<Renderer>().material.mainTexture as MovieTexture;
        mtex.Play();
    }

    // Update is called once per frame
    void Update()
    {
        if (!mtex.isPlaying)
        {
            print("movie playing status: " + mtex.isPlaying + ".");
            mtex.Play();
        }
    }
}

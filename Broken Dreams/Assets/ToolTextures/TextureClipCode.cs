using UnityEngine;
using System.Collections;

public class TextureClipCode : MonoBehaviour
{

    void Awake()
    {
        GetComponent<MeshRenderer>().enabled = false;
    }

}
using UnityEngine;
using System.Collections;

public class Computer : MonoBehaviour {

    public GameObject playerCamera;
    public GameObject player;
    public static bool isOnPC = false;
    bool pcActivator = true;

    void Update()
    {
        if (isOnPC && pcActivator)
            getOnPC();
    }

    void getOnPC()
    {
        playerCamera.GetComponent<Camera>().enabled = false;
        pcActivator = false;
    }
}

using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;
using UnityEngine.UI;

public class Computer : MonoBehaviour {

    public GameObject pcDisplay;
    public static bool isOnPC = false;
    bool pcActivator = true;

    void Update()
    {
       // Debug.Log(isOnPC);
        if(isOnPC && Input.GetKey(KeyCode.Escape))
        {
            isOnPC = false;
            pcDisplay.SetActive(false);
            LockMouse.lockMouse = true;
        }
        if(!isOnPC)
        {
            LockMouse.lockMouse = true;
        }
    }

    void FixedUpdate()
    {
        if (isOnPC)
            if (isOnPC)
        {
                pcDisplay.SetActive(true);
        }
    }
}

using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;
using UnityEngine.UI;

public class Computer : MonoBehaviour {

    public GameObject player;
    public GameObject pcDisplay;
    public static bool isOnPC = false;
    bool pcActivator = true;

    void Update()
    {
       // Debug.Log(isOnPC);
        if(isOnPC && Input.GetKey(KeyCode.Escape))
        {
            exitPC();
        }
        if(!isOnPC && !PhysicalJournal.isOnJournal)
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
                player.GetComponent<FirstPersonController>().enabled = false;
            }
    }

    public void exitPC()
    {
            isOnPC = false;
            pcDisplay.SetActive(false);
            LockMouse.lockMouse = true;
            player.GetComponent<FirstPersonController>().enabled = true;
    }
}

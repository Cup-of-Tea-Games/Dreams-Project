using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Exit : MonoBehaviour {

    public GameObject exitMenu;
    public GameObject player;
    public static bool exitStatus = false;

    public void showMessage()
    {
        exitStatus = true;
        exitMenu.SetActive(true);
        player.GetComponent<FirstPersonController>().enabled = false;
    }

    public void hideMessage()
    {
        exitStatus = false;
        exitMenu.SetActive(false);
        player.GetComponent<FirstPersonController>().enabled = true;
    }

    public void exit()
    {
        exitStatus = false;
        Application.Quit();
    }
}

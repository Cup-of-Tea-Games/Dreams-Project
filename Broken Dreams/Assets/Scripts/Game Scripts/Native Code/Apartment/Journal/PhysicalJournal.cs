using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;
using UnityEngine.UI;

public class PhysicalJournal : MonoBehaviour {

    public GameObject InventoryMenu;
    public GameObject player;
    public static bool isOnJournal = false;

    public void displayJournal()
    {
        isOnJournal = true;
        InventoryMenu.SetActive(true);
        LockMouse.lockMouse = false;
        player.GetComponent<FirstPersonController>().enabled = false;
    }

    public void hideJournal()
    {
        isOnJournal = false;
        InventoryMenu.SetActive(false);
        LockMouse.lockMouse = true;
        player.GetComponent<FirstPersonController>().enabled = true;
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.Escape))
            hideJournal();
    }
}

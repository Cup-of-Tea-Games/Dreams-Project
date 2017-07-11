using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;
using UnityEngine.UI;
public class InventoryMenu : MonoBehaviour {

    //public GameObject inventoryMenu;
    public static bool inventroyIsUp;
    bool canTrigger = true;

    //Base Coloroation
    Color32 colorBase;
    //Objects to fade in

    //Extra Objects
    public Selector selector;
    public ItemShack itemShack;
    public GameObject Inventory;

    void FixedUpdate () {
        if (Input.GetKey(KeyCode.Tab) && inventroyIsUp && canTrigger)
        {
            canTrigger = false;
            inventroyIsUp = false;
            LockMouse.lockMouse = true;
            StartCoroutine(waitTime());
        }
        else if (Input.GetKey(KeyCode.Tab) && !inventroyIsUp && canTrigger)
        {
            canTrigger = false;
            inventroyIsUp = true;
                LockMouse.lockMouse = false;
            StartCoroutine(waitTime());
        }

        if (inventroyIsUp)
        {
            objectsFadeIn();
            itemShack.enabled = true;
            selector.enabled = true;
                LockMouse.lockMouse = false;
        }
        else
        {
            objectsFadeOut();
            itemShack.enabled = false;
            selector.enabled = false;
            if(!PageViewer.PageViewerIsUp)
            LockMouse.lockMouse = true;
            if (!WeaponWheel.isShowing)
                LockMouse.lockMouse = true;
            if (!PauseMenu.isShowing)
                LockMouse.lockMouse = true;
        }
        if (PageViewer.PageViewerIsUp || WeaponWheel.isShowing || PauseMenu.isShowing)
        {
                LockMouse.lockMouse = false;
        }
        if (Computer.isOnPC)
        {
            LockMouse.lockMouse = false;
        }

    }

    public IEnumerator waitTime()
    {
        yield return new WaitForSeconds(0.5f);
        canTrigger = true;
        StopCoroutine(waitTime());
    }

    void objectsFadeIn()
    {
        Inventory.SetActive(true);
    }

    void objectsFadeOut()
    {
        Inventory.SetActive(false);
    }
}

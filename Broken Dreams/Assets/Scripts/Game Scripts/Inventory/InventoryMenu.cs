using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;
using UnityEngine.UI;
public class InventoryMenu : MonoBehaviour {

    //public GameObject inventoryMenu;
    public static bool inventroyIsUp = false;
    public static bool PauseIsUp = false;
    bool canTrigger = true;

    //Base Coloroation
    Color32 colorBase;
    //Objects to fade in

    //Extra Objects
    public Selector selector;
    public ItemShack itemShack;
    public GameObject Inventory;
    public GameObject pauseMenu;

    //SFX
    public AudioClip inventoryAppearSFX;
    public AudioClip pauseAppearSFX;

    void Awake()
    {
        Inventory.SetActive(false);
    }

    void FixedUpdate () {
        if (Input.GetKey(KeyCode.Tab) && inventroyIsUp && canTrigger && !PauseIsUp && PlayerHealth.health > 0)
        {
            objectsFadeOut();
            canTrigger = false;
            inventroyIsUp = false;
            LockMouse.lockMouse = true;
            StartCoroutine(waitTime());
        }
        else if (Input.GetKey(KeyCode.Tab) && !inventroyIsUp && canTrigger && !PauseIsUp && PlayerHealth.health > 0)
        {
            objectsFadeIn();
            canTrigger = false;
            inventroyIsUp = true;
                LockMouse.lockMouse = false;
            StartCoroutine(waitTime());
        }
        else if (Input.GetKey(KeyCode.Escape) && !inventroyIsUp && canTrigger && !PauseIsUp && PlayerHealth.health > 0)
        {
            pauseObjectsFadeIn();
            canTrigger = false;
            inventroyIsUp = false;
            PauseIsUp = true;
            LockMouse.lockMouse = false;
            StartCoroutine(waitTime());
        }
        else if (Input.GetKey(KeyCode.Escape) && !inventroyIsUp && canTrigger && PauseIsUp && PlayerHealth.health > 0)
        {
            pauseObjectsFadeOut();
            canTrigger = false;
            inventroyIsUp = false;
            PauseIsUp = false;
            LockMouse.lockMouse = true;
            StartCoroutine(waitTime());
        }

        if (inventroyIsUp)
        {
            itemShack.enabled = true;
            selector.enabled = true;
            LockMouse.lockMouse = false;
        }
        else if (PauseIsUp)
        {
            LockMouse.lockMouse = false;
        }
        else if (PlayerHealth.health < 1)
        {
            LockMouse.lockMouse = false;
        }
        else
        {
            itemShack.enabled = false;
            selector.enabled = false;
            if (!PageViewer.PageViewerIsUp)
                LockMouse.lockMouse = true;
            if (!WeaponWheel.isShowing)
                LockMouse.lockMouse = true;
            if (!PauseIsUp)
                LockMouse.lockMouse = true;
        }
        if (PageViewer.PageViewerIsUp || WeaponWheel.isShowing)
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
        GetComponent<AudioSource>().pitch = 1;
        GetComponent<AudioSource>().PlayOneShot(inventoryAppearSFX);
    }

    public void objectsFadeOut()
    {
        Inventory.SetActive(false);
        GetComponent<AudioSource>().pitch = 0.75f;
        GetComponent<AudioSource>().PlayOneShot(inventoryAppearSFX);
    }

    public void pauseObjectsFadeIn()
    {
        PauseIsUp = true;
        pauseMenu.SetActive(true);
        Time.timeScale = 0;
        GetComponent<AudioSource>().pitch = 1;
        GetComponent<AudioSource>().PlayOneShot(pauseAppearSFX);
    }

    public void pauseObjectsFadeOut()
    {
        PauseIsUp = false;
        pauseMenu.SetActive(false);
        Time.timeScale = 1;
        GetComponent<AudioSource>().pitch = 0.75f;
        GetComponent<AudioSource>().PlayOneShot(pauseAppearSFX);
    }
}

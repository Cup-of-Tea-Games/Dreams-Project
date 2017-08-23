using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class WeaponKey : MonoBehaviour {

    public Camera player;
    public float range = 5;
    public string tag;
    public Image crosshair;
    public Sprite recieverSprite;
    private Sprite originalSprite;
    public WeaponWheel weaponWheel;

    void Awake()
    {
        originalSprite = crosshair.sprite;
    }

    void Update()
    {
        checkKeyReciever();
    }

    void checkKeyReciever()
    {
        RaycastHit hit;
        if (Physics.Raycast(player.transform.position, player.transform.forward, out hit, range, 1 << LayerMask.NameToLayer("Default")))
        {

            if (hit.transform.GetComponent<KeyReciever>() != null)
            {
                if (tag == hit.transform.GetComponent<KeyReciever>().tagName)
                {
                    crosshair.sprite = recieverSprite;

                    disableComponents();

                    if (Input.GetMouseButtonUp(0) && !WeaponWheel.isShowing)
                    {
                        weaponWheel.removeItem();
                        hit.transform.GetComponent<KeyReciever>().insertWeapon(tag);
                    }

                }
            }
            else
            {
                crosshair.sprite = originalSprite;
                enableComponents();
            }
        }

        else
        {
            crosshair.sprite = originalSprite;
            enableComponents();
        }
    }

    void disableComponents()
    {
        if (GetComponent<WeaponInteraction>() != null)
        {
            GetComponent<WeaponInteraction>().enabled = false;
        }
        if (GetComponent<MeleeWeapon>() != null)
        {
            GetComponent<MeleeWeapon>().enabled = false;
        }
    }

    void enableComponents()
    {
        if (GetComponent<WeaponInteraction>() != null)
        {
            GetComponent<WeaponInteraction>().enabled = true;
        }
        if (GetComponent<MeleeWeapon>() != null)
        {
            GetComponent<MeleeWeapon>().enabled = true;
        }
    }
}

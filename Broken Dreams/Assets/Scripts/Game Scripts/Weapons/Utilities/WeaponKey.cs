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
          //  Debug.Log(tag + " " + hit.transform.GetComponent<KeyReciever>().tag);

            if (hit.transform.GetComponent<KeyReciever>() != null)
            {
                if (tag == hit.transform.GetComponent<KeyReciever>().tagName)
                {
                    crosshair.sprite = recieverSprite;
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
            }
        }
    }
}

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class WeaponInteraction : MonoBehaviour
{

    public Animator animator;
    public Camera player;
    public float range = 3;
    public Image crosshair;
    public Sprite toggle;
    public Sprite door;
    private Sprite originalSprite;

    void Awake()
    {
        originalSprite = crosshair.sprite;
    }

    void Update()
    {
        RaycastHit hit;
        if (Physics.Raycast(player.transform.position, player.transform.forward, out hit, range, 1 << LayerMask.NameToLayer("Default")))
        {
            //  Debug.Log(tag + " " + hit.transform.GetComponent<KeyReciever>().tag);

            if (hit.transform.GetComponent<Door>() != null)
            {
                disableComponents();
                animator.Play("Lower");
                crosshair.sprite = door;
                if (Input.GetMouseButtonUp(0) && !WeaponWheel.isShowing)
                {
                    hit.transform.GetComponent<Door>().toggle();
                    animator.Play("Door");
                    enableComponents();
                }

            }
            else if (hit.transform.GetComponent<Toggle>() != null)
            {
                disableComponents();
                animator.Play("Lower");
                crosshair.sprite = toggle;
                if (Input.GetMouseButtonUp(0) && !WeaponWheel.isShowing)
                {
                    hit.transform.GetComponent<Toggle>().toggle();
                    animator.Play("Toggle");
                    enableComponents();
                }
            }
            else if (hit.transform.GetComponent<Button>() != null)
            {
                disableComponents();
                animator.Play("Lower");
                crosshair.sprite = toggle;
                if (Input.GetMouseButtonUp(0) && !WeaponWheel.isShowing)
                {
                    hit.transform.GetComponent<Button>().activate();
                    animator.Play("Toggle");
                    enableComponents();
                }
            }

            else
            {
                if (this.animator.GetCurrentAnimatorStateInfo(0).IsName("Lower"))
                {
                    enableComponents();
                    animator.Play("Idle");
                }
                if(GetComponent<WeaponKey>() != null)
                crosshair.sprite = originalSprite;
            }
        }

        else
        {
            if (this.animator.GetCurrentAnimatorStateInfo(0).IsName("Lower"))
            {
                enableComponents();
                animator.Play("Idle");

            }
            crosshair.sprite = originalSprite;
        }
    }

    void disableComponents()
    {
        if (GetComponent<Handgun>() != null)
        {
            GetComponent<Handgun>().enabled = false;
        }
        if (GetComponent<MeleeWeapon>() != null)
        {
            GetComponent<MeleeWeapon>().enabled = false;
        }
        if (GetComponent<Flashlight>() != null)
        {
            GetComponent<Flashlight>().enabled = false;
        }
    }

    void enableComponents()
    {
        if (GetComponent<Handgun>() != null)
        {
            GetComponent<Handgun>().enabled = true;
        }
        if (GetComponent<MeleeWeapon>() != null)
        {
            GetComponent<MeleeWeapon>().enabled = true;
        }
        if (GetComponent<Flashlight>() != null)
        {
            GetComponent<Flashlight>().enabled = true;
        }
    }
}

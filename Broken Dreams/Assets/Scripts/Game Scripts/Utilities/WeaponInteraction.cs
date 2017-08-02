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
                    holdAttack();
                    animator.Play("Lower");
                    crosshair.sprite = door;
                    if (Input.GetMouseButtonUp(0) && !WeaponWheel.isShowing)
                    {
                    hit.transform.GetComponent<Door>().toggle();
                    animator.Play("Door");
                    releaseAttack();
                }

                }
                else if (hit.transform.GetComponent<Toggle>() != null)
                {
                    holdAttack();
                    animator.Play("Lower");
                    crosshair.sprite = toggle;
                    if (Input.GetMouseButtonUp(0) && !WeaponWheel.isShowing)
                    {
                    hit.transform.GetComponent<Toggle>().toggle();
                    animator.Play("Toggle");
                    releaseAttack();
                }

                }
            
            else
            {
                if (this.animator.GetCurrentAnimatorStateInfo(0).IsName("Lower"))
                {
                    releaseAttack();
                    animator.Play("Idle");
                }
                crosshair.sprite = originalSprite;
            }
        }

        else
        {
            if (this.animator.GetCurrentAnimatorStateInfo(0).IsName("Lower"))
            {
                releaseAttack();
                animator.Play("Idle");

            }
            crosshair.sprite = originalSprite;
        }
    }

    void holdAttack()
    {
        if(GetComponent<Handgun>() != null)
        GetComponent<Handgun>().canShoot = false;
        if (GetComponent<MeleeWeapon>() != null)
            GetComponent<MeleeWeapon>().canAttack = false;
    }

    void releaseAttack()
    {
        if (GetComponent<Handgun>() != null)
            GetComponent<Handgun>().canShoot = true;
        if (GetComponent<MeleeWeapon>() != null)
            GetComponent<MeleeWeapon>().canAttack = true;
    }
}

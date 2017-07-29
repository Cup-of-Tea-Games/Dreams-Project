using UnityEngine;
using System.Collections;

public class Flashlight : MonoBehaviour {

    //Health
    public static float health;
    public Light spotlight;
    bool toggleSwitch = false;

    //Animation
    public Animator animator;

    //Functionality

  //  public Camera player;
  //  public float damage = 5;
  //  public float range = 5;
  //  public float force = 5;
    bool canSwitch = true;

    //VIsuals

 //   public GameObject flashEffect;
    // public ParticleSystem muzzleFlash;

    void Update()
    {
        //Animations

        //Attack
        if (!WeaponWheel.isShowing)
        {
            if (Input.GetMouseButtonDown(0))
            {
                if (canSwitch)
                    StartCoroutine(Switch(1f));
            }
            if (Input.GetKey(KeyCode.R))
            {
                Reload();
            }
        }

    }

    IEnumerator Switch(float x)
    {
        canSwitch = false;
        animator.Play("Switch");
        yield return new WaitForSeconds(x/2);
        Toggle();
        yield return new WaitForSeconds(x);
        canSwitch = true;
        StopCoroutine(Switch(x));
    }
    void Reload()
    {
        animator.Play("Reload");
    }

    //Functionality

    void Toggle()
    {
        toggleSwitch = !toggleSwitch;
        spotlight.enabled = toggleSwitch;
    }


    /*
    void Fire()
    {
        //   muzzleFlash.Play();

        RaycastHit hit;
        if (Physics.Raycast(player.transform.position, player.transform.forward, out hit, range, 1 << LayerMask.NameToLayer("Default")))
        {
            Debug.Log(hit.transform.name);

            if (hit.transform.GetComponent<DestroyableObject>() != null)
            {
                hit.transform.GetComponent<DestroyableObject>().takeDamage(damage);
            }

            else if (hit.transform.GetComponent<DamagePoint>() != null)
            {
                hit.transform.GetComponent<DamagePoint>().takeDamage(damage);
            }

            if (hit.rigidbody != null)
            {
                hit.rigidbody.AddForce(-hit.normal * 1000 * force);
            }

            GameObject effectParticle = Instantiate(impactEffect, hit.point, Quaternion.LookRotation(hit.normal)) as GameObject;
            Destroy(effectParticle, 2f);
        }
    }

    */
}

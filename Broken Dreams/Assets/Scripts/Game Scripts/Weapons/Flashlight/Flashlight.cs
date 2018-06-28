using UnityEngine;
using System.Collections;

public class Flashlight : MonoBehaviour {

    //Health
    protected float batteries;
    protected float health;
    public Light spotlight;
    bool toggleSwitch = false;

    //Animation
    public Animator animator;

    //Functionality

    public float startingBatteryHealth;
    public float startingBatteries;
    public bool canSwitch = true;

    //VIsuals

 //   public GameObject flashEffect;
    // public ParticleSystem muzzleFlash;

    void Awake()
    {
        health = startingBatteryHealth;
        batteries = startingBatteries;
    }

    void Update()
    {
        if (!WeaponWheel.isShowing && !InventoryMenu.inventroyIsUp)
        {
            if (Input.GetMouseButtonDown(0))
            {
                if (canSwitch && health > 0)
                    StartCoroutine(Switch(1f));
            }
            if (Input.GetKey(KeyCode.R))
            {
                if(batteries > 0)
                StartCoroutine(Reload());
            }
        }

        if (toggleSwitch)
        {
            health = Mathf.Clamp(health - 0.05f, 0, 100);

            if (health <= 40 && health >= 39)
                StartCoroutine(BangFlashlight());

            else if (health <= 20 && health >= 19)
                StartCoroutine(BangFlashlight());

            if (health <= 0)
            {
                Toggle();
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

    IEnumerator Reload()
    {
        animator.Play("Reload");
        yield return new WaitForSeconds(0.9f);
        if (toggleSwitch)
            Toggle();
        yield return new WaitForSeconds(1.8f);
        if (!toggleSwitch)
        {
            Toggle();
            ReloadBatteries();
        }

        StopCoroutine(Reload());
    }

    IEnumerator BangFlashlight()
    {
        Flicker();
        yield return new WaitForSeconds(1f);
        animator.Play("Bang");
        StopCoroutine(BangFlashlight());
    }

    //Functionality

    void Toggle()
    {
        toggleSwitch = !toggleSwitch;
        spotlight.enabled = toggleSwitch;
    }

    void Flicker()
    {
        for (int i = 0;i<50;i++)
        {
            spotlight.enabled = !spotlight.enabled;
        }
        spotlight.enabled = true;
    }

    void ReloadBatteries()
    {
        health = 100;
        batteries -= 1;
    }

    //Getters

    public float getHealth()
    {
        return health;
    }

    public float getBatteries()
    {
        return batteries;
    }

    //Setters
    public void addBatteries(int x)
    {
        batteries += x;
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

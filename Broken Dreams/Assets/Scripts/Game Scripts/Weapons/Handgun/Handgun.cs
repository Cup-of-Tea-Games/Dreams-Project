using UnityEngine;
using System.Collections;

public class Handgun : MonoBehaviour {

    //Animation
    public Animator animator;

    //Functionality

    public Camera player;
    public float damage = 5;
    public float range = 5;
    public float force = 5;
    public float fireRateDelay = 0.35f;
    bool canShoot = true;

    //VIsuals

    public GameObject impactEffect;
   // public ParticleSystem muzzleFlash;
   
    void Update()
    {
        //Animations

        //Attack
        if (!WeaponWheel.isShowing)
        {
            if (Input.GetMouseButton(0))
            {
                if (canShoot)
                    StartCoroutine(Shoot(fireRateDelay));
            }
            if (Input.GetKey(KeyCode.R))
                Reload();
        }

    }

    IEnumerator Shoot(float x)
    {
        canShoot = false;
        int rand = Random.RandomRange(1, 3);
        switch (rand)
        {
            case 1:
                animator.Play("Shoot1");
                break;
            case 2:
                animator.Play("Shoot2");
                break;
        }
        if (!(this.animator.GetCurrentAnimatorStateInfo(1).IsName("Shoot1") && this.animator.GetCurrentAnimatorStateInfo(1).IsName("Shoot2")))
            Fire();
        yield return new WaitForSeconds(x);
        canShoot = true;
        StopCoroutine(Shoot(x));
    }

    void Reload()
    {
       animator.Play("Reload");
    }



    //Functionality

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
}

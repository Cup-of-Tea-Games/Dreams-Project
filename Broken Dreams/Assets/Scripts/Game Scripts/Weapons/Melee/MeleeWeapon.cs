using UnityEngine;
using System.Collections;

public class MeleeWeapon : MonoBehaviour {

    //Animation
    public Animator animator;
    bool attackSwitch = true;
    public bool isInHitArea = false;

    //Functionality

    public Camera player;
    public float damage = 5;
    public float range = 5;
    public float force = 5;

    //VIsuals

    public GameObject impactEffect;

    void Awake()
    {
        isInHitArea = false;
    }

    void Update()
    {
        //Animations

        //Attack
        if (Input.GetMouseButtonDown(0) && !WeaponWheel.isShowing)
        {
            StopCoroutine(ReturnAnimation(0f));
            //Attack
            StartCoroutine(AttackAnimation(0.13f));
        }
        else if (!Input.GetMouseButtonDown(0))
        {
            StartCoroutine(ReturnAnimation(2f));
        }

    }

    //Animations
    IEnumerator ReturnAnimation(float x)
    {
        yield return new WaitForSeconds(x);
        attackSwitch = false;
        StopCoroutine(ReturnAnimation(x));
    }

    IEnumerator AttackAnimation(float x)
    {
        animator.Play("Attack1");
        yield return new WaitForSeconds(0);
                attackSwitch = true;
        if(isInHitArea)
        Attack();

        StopCoroutine(AttackAnimation(x));
    }

    //Functionality

    void Attack()
    {
        RaycastHit hit;
        if (Physics.Raycast(player.transform.position, player.transform.forward, out hit, range, 1 << LayerMask.NameToLayer("Default")))
        {
            Debug.Log(hit.transform.name);

            if (hit.transform.GetComponent<DestroyableObject>() != null)
            {
                hit.transform.GetComponent<DestroyableObject>().takeDamage(damage);
            }

            if(hit.rigidbody != null)
            {
                hit.rigidbody.AddForce(-hit.normal * 1000 * force);
            }

            GameObject effectParticle = Instantiate(impactEffect, hit.point, Quaternion.LookRotation(hit.normal)) as GameObject;
            Destroy(effectParticle, 2f);
        }
    }
}

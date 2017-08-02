using UnityEngine;
using System.Collections;

public class MeleeWeapon : MonoBehaviour {

    //Animation
    public Animator animator;
    bool attackSwitch = true;
    public bool canAttack = true;
    public bool isInHitArea = false;

    //Functionality

    public Camera player;
    public float damage = 5;
    public float range = 5;
    public float force = 5;
    public float AttackRateDelay = 0.35f;
    public bool isAnimationBased = false;
    public HitPoint hitPoint;

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
        if (!WeaponWheel.isShowing)
        {
            if (Input.GetMouseButton(0))
            {
                StopCoroutine(ReturnAnimation(0f));
                //Attack
                if(canAttack)
                StartCoroutine(AttackAnimation(AttackRateDelay));
            }
            if (Input.GetKey(KeyCode.R))
            {
                Reload();
            }

            if (isAnimationBased)
                if (hitPoint.acitve)
                    Attack();
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
        canAttack = false;
        int rand = Random.RandomRange(1, 3);
        switch (rand)
        {
            case 1:
                animator.CrossFade("Attack1",0f);
                break;
            case 2:
                animator.CrossFade("Attack2",0f);
                break;
        }
        yield return new WaitForSeconds(x);
        canAttack = true;
        if (!isAnimationBased)
        {
            attackSwitch = true;
            Attack();
        }

        StopCoroutine(AttackAnimation(x));

    }

    void Reload()
    {
        animator.Play("Reload");
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

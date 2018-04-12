using UnityEngine;
using System.Collections;
using UnityEngine.UI;

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
    public ParticleHitManager particleManager;
    public Image crosshair;

    //VIsuals
    public bool hasEffect = false;
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
        rangeCheck();
    }

    void rangeCheck()
    {
        RaycastHit hit;
        if (Physics.Raycast(player.transform.position, player.transform.forward, out hit, range, 1 << LayerMask.NameToLayer("Default")))
        {
            if (crosshair != null)
            {
                if (hit.collider.GetComponent<DamageSystem>() != null || hit.collider.GetComponent<DamagePoint>() != null)
                {
                    crosshair.color = Color.red;
                }
                else
                {
                    crosshair.color = Color.white;
                }
            }
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

    void manageEffects()
    {
        RaycastHit hit;

        if (Physics.Raycast(player.transform.position, player.transform.forward, out hit, range, 1 << LayerMask.NameToLayer("Default")))
        {
            //Declares Components

            GameObject impactEffect = null;
            GameObject impactDecal = null;
            AudioClip impactSound = null;

            //Find out what type of material we're dealing with

            string tag; //Tag of object you're hitting

            if (hit.collider.gameObject.GetComponent<MaterialInfo>() != null)
                tag = hit.collider.gameObject.GetComponent<MaterialInfo>().materialTag;
            else
                tag = "Generic";

            MaterialObject curentObject = particleManager.getMaterialObject(tag);
            impactEffect = curentObject.particleEffect;
            impactDecal = curentObject.decal;



            //Make Sure the components aren't missing

            if (impactEffect != null)
            {
                GameObject effectParticle = Instantiate(impactEffect, hit.point, Quaternion.LookRotation(hit.normal)) as GameObject;
                Destroy(effectParticle, 2f);
            }

            if (impactDecal != null)
            {
                GameObject effectDecal = GameObject.Instantiate(impactDecal, hit.point, Quaternion.LookRotation(hit.normal));
                Destroy(effectDecal, 10f);
            }

            if (hasEffect)
            {
                GetComponent<AudioSource>().Play();
            }
        }
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

            manageEffects();
        }
    }
}

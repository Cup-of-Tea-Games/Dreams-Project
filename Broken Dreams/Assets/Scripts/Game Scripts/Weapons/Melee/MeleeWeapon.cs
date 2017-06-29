using UnityEngine;
using System.Collections;

public class MeleeWeapon : MonoBehaviour {

    public Animator animator;
    bool attackSwitch = true;

    void Update()
    {
        //Debug.Log("AAAAAAAAAAAAAAAAAAAA" + holdDown);
        if (Input.GetMouseButtonDown(0) && !WeaponWheel.isShowing)
        {
            StopCoroutine(ReturnAnimation(0f));
            StartCoroutine(AttackAnimation(0.0f));
        }
        else if (!Input.GetMouseButtonDown(0))
        {
            StartCoroutine(ReturnAnimation(2f));
        }

    }

    IEnumerator ReturnAnimation(float x)
    {
        yield return new WaitForSeconds(x);
        attackSwitch = false;
        StopCoroutine(ReturnAnimation(x));
    }

    IEnumerator AttackAnimation(float x)
    {
        animator.Play("Attack1");
        yield return new WaitForSeconds(x);
                attackSwitch = true;

        StopCoroutine(AttackAnimation(x));
    }
}

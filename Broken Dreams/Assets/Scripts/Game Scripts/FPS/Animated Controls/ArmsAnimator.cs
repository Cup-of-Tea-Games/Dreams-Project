using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Utility;

public class ArmsAnimator : MonoBehaviour {

    public Animator m_Animator;
    public Animator bodyAnimator;
    public GameObject leftShoulder;
    public GameObject rightShoulder;
    private WeaponWheel weaponWheel;

    void Awake()
    {

        GameObject tempWeapon = GameObject.Find("Weapon Wheel");
        weaponWheel = tempWeapon.GetComponent<WeaponWheel>();
    }

    void Update()
    {
        m_Animator.SetFloat("Forward", bodyAnimator.GetFloat("Forward"), 0.1f, Time.deltaTime);
        m_Animator.SetFloat("Side", bodyAnimator.GetFloat("Side"), 0.1f, Time.deltaTime);
        m_Animator.SetBool("Crouch", bodyAnimator.GetBool("Crouch"));
        m_Animator.SetBool("OnGround", bodyAnimator.GetBool("OnGround"));

        if (WeaponWheel.numSwitch > 0)
            rightShoulder.GetComponent<FollowTarget>().enabled = false;
        else
            rightShoulder.GetComponent<FollowTarget>().enabled = true;

        if (WeaponWheel.numSwitch == 4)
        {
            leftShoulder.GetComponent<FollowTarget>().enabled = false;
        }
        else
        {
            leftShoulder.GetComponent<FollowTarget>().enabled = true;
        }

        Debug.Log(WeaponWheel.numSwitch);

    }
}

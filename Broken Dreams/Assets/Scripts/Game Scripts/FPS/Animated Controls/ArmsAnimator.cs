using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArmsAnimator : MonoBehaviour {

    public Animator m_Animator;
    public Animator bodyAnimator;

    void Update()
    {
        m_Animator.SetFloat("Forward", bodyAnimator.GetFloat("Forward"), 0.1f, Time.deltaTime);
        m_Animator.SetFloat("Side", bodyAnimator.GetFloat("Side"), 0.1f, Time.deltaTime);
        m_Animator.SetBool("Crouch", bodyAnimator.GetBool("Crouch"));
        m_Animator.SetBool("OnGround", bodyAnimator.GetBool("OnGround"));
    }
}

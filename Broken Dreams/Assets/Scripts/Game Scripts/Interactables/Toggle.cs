﻿using UnityEngine;
using System.Collections;

public class Toggle : MonoBehaviour
{

    bool togglebool = false;
    public GameObject toggleObject;
    AudioSource audio;
    public bool isSwitch = false;
    public bool isVirtual = false;
    public GameObject ONobj;
    public GameObject OFFobj;
    public bool hasAnimation = false;
    public bool initialState = false;
    Animator anim;

    void Awake()
    {
        audio = GetComponent<AudioSource>();
        togglebool = initialState;
        if(hasAnimation)
        anim = toggleObject.GetComponent<Animator>();
    }

    public void toggle()
    {
        togglebool = !togglebool;
        if(!isVirtual)
        audio.Play();
        if(!hasAnimation)
        toggleObject.SetActive(togglebool);

        if (hasAnimation)
            anim.enabled = togglebool;

        if (isSwitch)
        {
            if (togglebool)
            {
                ONobj.SetActive(true);
                OFFobj.SetActive(false);
            }
            else
            {
                ONobj.SetActive(false);
                OFFobj.SetActive(true);
            }

        }
    }

    public bool currentState()
    {
        return togglebool;
    }

}

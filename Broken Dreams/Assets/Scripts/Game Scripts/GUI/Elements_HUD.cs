using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Elements_HUD : MonoBehaviour {

    public GameObject Health_Icon;
    public GameObject Sanity_Icon;

    Animator Health_Anim;
    Animator Sanity_Anim;

    //Verifiers
    bool HUDisUp = false;

    void Awake()
    {
       Health_Anim = Health_Icon.GetComponent<Animator>();
       Sanity_Anim = Sanity_Icon.GetComponent<Animator>();
    }

    void Update()
    {
        HUD_Handeler();
    }
    //Show HUD
    void ShowAll()
    {
        Health_Anim.Play("Appear");
        Sanity_Anim.Play("Appear");

        HUDisUp = true;
    }
    //Hide HUD
    void HideAll()
    {
        Health_Anim.Play("Disappear");
        Sanity_Anim.Play("Disappear");

        HUDisUp = false;
    }
    //Decreasers Low and Big Levels
    void DecreaseSanity_Slow()
    {
        Sanity_Anim.Play("Affected");
    }
    void DecreaseSanity_Fast()
    {
        Sanity_Anim.Play("Hurting");
    }

    void DecreaseHealth_Slow()
    {
        Health_Anim.Play("Affected");
    }
    void DecreaseHealth_Fast()
    {
        Health_Anim.Play("Hurting");
    }


    void HUD_Handeler()
    {
        //General
        if(PlayerSanity.isDraining || PlayerHealth.InDanger)
        {
            if(!HUDisUp)
            ShowAll();
        }
        else
        {
            if(HUDisUp)
            HideAll();
        }

        //Sanity
        if (PlayerSanity.sanity >= 50 && PlayerSanity.isDraining && HUDisUp && PlayerSanity.isDraining)
        {
            DecreaseSanity_Slow();
        }
        else if (PlayerSanity.sanity < 50 && HUDisUp && PlayerSanity.isDraining)
        {
            DecreaseSanity_Fast();
        }

        //Health
        if (PlayerHealth.health >= 50 && HUDisUp && PlayerHealth.InDanger)
        {
            DecreaseHealth_Slow();
        }
        else if (PlayerHealth.health < 50 && HUDisUp && PlayerHealth.InDanger)
        {
            DecreaseHealth_Fast();
        }
    }
}

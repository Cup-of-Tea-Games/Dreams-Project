using UnityEngine;
using System.Collections;
using ProgressBar;
using UnityEngine.UI;
using UnityStandardAssets.ImageEffects;
using UnityStandardAssets.Characters.FirstPerson;

public class PlayerHealth : MonoBehaviour {

    public ProgressRadialBehaviour healthBar;
    public GameObject barFiller;
    public GameObject healthIcon;
    Color32 currentColor;
    public static float health;
    public bool constantDepletion;

    //Colors shining
    public Color32[] c;

    //Condition of Health
    public GameObject player;
    AudioLowPassFilter filter;
    ColorCorrectionCurves visionColor;

    //Tips
    public TipsGenerator Tip;

    //Damage System
    public DamageMe damageSystem;
    //Damage System - Death
    public GameObject playerBody;//This is for controlling the crouching and using it to simulate death
    public GameObject playerCamera;
    CharacterController body;

    //SFX
    public AudioSource SFX_heartBeatSound;
    public AudioSource SFX_deathSound;

    //tools
    bool isGettingHurt;
    bool isDead;

    public static bool InDanger;

    void Awake()
    {
        filter = player.GetComponent<AudioLowPassFilter>();
        visionColor = player.GetComponent<ColorCorrectionCurves>();
        health = 100;

        //Damage System - Death
        body = playerBody.GetComponent<CharacterController>();
    }

    void HealthBarMonitor()
    {
        barFiller.GetComponent<Image>().color = currentColor;
        healthIcon.GetComponent<Image>().color = currentColor;

        if (health >= 100)
            isDead = false;

        if (health >= 90)
        {
            currentColor = c[0];
            visionColor.saturation = 1.4f;
            SFX_heartBeatSound.mute = true;
            filter.enabled = false;

        }
        else if (health < 90 && health >= 80)
        {
            currentColor = c[1];
            visionColor.saturation = 1.4f;
            SFX_heartBeatSound.mute = true;
            filter.enabled = false;
        }
        else if (health < 80 && health >= 70)
        {
            currentColor = c[2];
            visionColor.saturation = 1.4f;
            SFX_heartBeatSound.mute = true;
            filter.enabled = false;
        }
        else if (health < 70 && health >= 60)
        {
            currentColor = c[3];
            visionColor.saturation = 1.0f;
            SFX_heartBeatSound.mute = true;
            filter.enabled = false;
        }
        else if (health < 60 && health >= 50)
        {
            currentColor = c[4];
            visionColor.saturation = 1.0f;
            SFX_heartBeatSound.mute = true;
            filter.enabled = false;
            if (isGettingHurt)
                Tip.Show("Your health is getting low, find a safe place to heal.");
        }
        else if (health < 50 && health >= 40)
        {
            currentColor = c[5];
            visionColor.saturation = 0.5f;
            SFX_heartBeatSound.mute = false;
            filter.enabled = true;
            InDanger = true;
        }
        else if (health < 40 && health >= 30)
        {
            currentColor = c[6];
            visionColor.saturation = 0.5f;
            SFX_heartBeatSound.mute = false;
            filter.enabled = true;
            InDanger = true;
        }
        else if (health < 30 && health >= 20)
        {
            currentColor = c[7];
            visionColor.saturation = 0.0f;
            SFX_heartBeatSound.mute = false;
            filter.enabled = true;
            if (isGettingHurt)
                Tip.Show("Your health is dangerously low. Heal as soon as possible.");
            InDanger = true;
        }
        else if (health < 20 && health >= 10)
        {
            currentColor = c[8];
            visionColor.saturation = 0.0f;
            SFX_heartBeatSound.mute = false;
            filter.enabled = true;
            InDanger = true;
        }
        else if (health < 10 && health > 0)
        {
            currentColor = c[9];
            visionColor.saturation = 0.0f;
            SFX_heartBeatSound.mute = false;
            filter.enabled = true;
            InDanger = true;
        }

        else if (health <= 0 && health > -100)
        {
            Die();
            health = -100;
        }

    }

    void Die()
    {
        playerBody.GetComponent<FirstPersonController>().enabled = false;
        playerBody.GetComponent<Rigidbody>().isKinematic = false;
        playerBody.GetComponent<Rigidbody>().freezeRotation = true;
        playerCamera.transform.Rotate(0, 0, 45, 0);
        body.enabled = false;
        if (!isDead)
            SFX_deathSound.Play();
        isDead = true;
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.tag == "Danger")
        {
            damageSystem.takeDamage(40);
            isGettingHurt = true;

        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.tag == "Danger")
        {
            isGettingHurt = false;

        }
    }

    public static bool isAlive()
    {
        return (health > 0);
    }

    void Update()
    {
        healthBar.Value = health;
        HealthBarMonitor();

        if (constantDepletion)
            damageSystem.takeDamage(10);

        if (health > 100)
            health = 100;

       if (playerBody.GetComponent<Rigidbody>().velocity.y < - 7 && playerBody.GetComponent<CharacterController>().isGrounded && FirstPersonController.airTime > 0.65f )
       {
            playerBody.GetComponent<Rigidbody>().isKinematic = true;
            damageSystem.takeDamage(25);
       }
       else if (!playerBody.GetComponent<CharacterController>().isGrounded && !FirstPersonController.isClimbing)
        {
            playerBody.GetComponent<Rigidbody>().isKinematic = false;
        }
       else
        {
            playerBody.GetComponent<Rigidbody>().isKinematic = true;
        }

        Debug.Log(FirstPersonController.airTime);
    }

}

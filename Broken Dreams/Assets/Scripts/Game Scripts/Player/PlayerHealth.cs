using UnityEngine;
using System.Collections;
using ProgressBar;
using UnityEngine.UI;
using UnityStandardAssets.ImageEffects;
using UnityStandardAssets.Characters.FirstPerson;
using UnityStandardAssets.Utility;

public class PlayerHealth : MonoBehaviour {

    public ProgressRadialBehaviour healthBar;
    public GameObject barFiller;
    public GameObject healthIcon;
    public ProgressRadialBehaviour healthBar2;
    public GameObject barFiller2;
    public GameObject healthIcon2;
    Color32 currentColor;
    public static float health;
    public float initialHealth;
    public bool constantDepletion;

    //Ragdoll Damage
    public GameObject Rig;
    public GameObject Arms;
    public GameObject CameraAxis;

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
        health = initialHealth;

        //Damage System - Death
        body = playerBody.GetComponent<CharacterController>();


        foreach (Collider col in Rig.GetComponentsInChildren<Collider>())
            if (GetComponentsInChildren<Collider>() != null)
                col.enabled = false;

        foreach (Collider col in Arms.GetComponentsInChildren<Collider>())
            if (GetComponentsInChildren<Collider>() != null)
                col.enabled = false;
    }

    void HealthBarMonitor()
    {
        barFiller.GetComponent<Image>().color = currentColor;
        healthIcon.GetComponent<Image>().color = currentColor;
        barFiller2.GetComponent<Image>().color = currentColor;
        healthIcon2.GetComponent<Image>().color = currentColor;

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
            visionColor.saturation = 0.0f;
            health = -100;
        }

    }

    void Die()
    {
        playerBody.GetComponent<FirstPersonController>().enabled = false;
        playerBody.GetComponent<Rigidbody>().isKinematic = false;
        player.GetComponent<Camera>().nearClipPlane = 0.01f;
        body.enabled = false;
        if (!isDead)
            SFX_deathSound.Play();
        isDead = true;

        CameraAxis.GetComponent<FollowTarget>().copyRotation = true;

        playerBody.transform.DetachChildren();
        Arms.transform.parent = Rig.transform;
        // CameraAxis.transform.parent = Rig.transform;

        //Ragdoll
        foreach (Collider col in Rig.GetComponentsInChildren<Collider>())
            if (GetComponentsInChildren<Collider>() != null)
                col.enabled = true;

        foreach (Collider col in Arms.GetComponentsInChildren<Collider>())
            if (GetComponentsInChildren<Collider>() != null)
                col.enabled = true;

        foreach (Rigidbody rb in Rig.GetComponentsInChildren<Rigidbody>())
            if (GetComponentsInChildren<Rigidbody>() != null)
                rb.isKinematic = false;

        foreach (Animator an in Rig.GetComponentsInChildren<Animator>())
            if (GetComponentsInChildren<Animator>() != null)
                an.enabled = false;

        foreach (Rigidbody rb in Arms.GetComponentsInChildren<Rigidbody>())
            if (GetComponentsInChildren<Rigidbody>() != null)
                rb.isKinematic = false;

        foreach (Animator an in Arms.GetComponentsInChildren<Animator>())
            if (GetComponentsInChildren<Animator>() != null)
                an.enabled = false;

        foreach (FollowTarget ft in Arms.GetComponentsInChildren<FollowTarget>())
                 if (GetComponentsInChildren<FollowTarget>() != null)
                     ft.enabled = false;

        foreach (ArmsAnimator am in Arms.GetComponentsInChildren<ArmsAnimator>())
            if (GetComponentsInChildren<ArmsAnimator>() != null)
                am.enabled = false;

        //  animator.enabled = false;
        //  transform.DetachChildren();
        //  Destroy(gameObject, 0.2f);
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.GetComponent<Damager>() != null && !col.GetComponent<Damager>().isProgressive)
        {
            damageSystem.takeDamage(col.GetComponent<Damager>().damageAmount);
            isGettingHurt = true;

        }
        else if (col.GetComponent<Damager>() != null && col.GetComponent<Damager>().isProgressive)
        {
            damageSystem.enterProgressiveDamageArea(col.GetComponent<Damager>().damageAmount);
            isGettingHurt = true;

        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.tag == "Danger")
        {
            isGettingHurt = false;

        }

        else if (col.tag == "Progressive Danger")
        {
            damageSystem.exitProgressiveDamageArea();
        }

        else if (col.tag == "Instant Death")
        {
            Die();
        }
    }

    public static bool isAlive()
    {
        return (health > 0);
    }

    void Update()
    {
        healthBar.Value = health;
        healthBar2.Value = health;
        HealthBarMonitor();

        if (constantDepletion)
            damageSystem.takeDamage(10);

        if (health > 100)
            health = 100;

        if (health <= 100)
            health += Time.deltaTime / 2;

        if (playerBody.GetComponent<Rigidbody>().velocity.y < - 7 && playerBody.GetComponent<CharacterController>().isGrounded && FirstPersonController.airTime > 0.65f )
       {
            playerBody.GetComponent<Rigidbody>().isKinematic = true;
            if(!WaterInteraction.isOnWater)
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

    }

}

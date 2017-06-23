using UnityEngine;
using System.Collections;
using ProgressBar;
using UnityEngine.UI;
using UnityStandardAssets.ImageEffects;
using UnityStandardAssets.Characters.FirstPerson;

public class PlayerSanity : MonoBehaviour {

    public ProgressRadialBehaviour sanityBar;
    public GameObject barFiller;
    public GameObject sanityIcon;
    public ProgressRadialBehaviour sanityBar2;
    public GameObject barFiller2;
    public GameObject sanityIcon2;
    Color32 currentColor;
    public static float sanity;
    public bool constantDepletion;

    //Colors shining
    public Color32[] c;
    public Color normalColor;
    public Color depletingColor;

    //Condition of sanity
    public GameObject player;
    public AudioEchoFilter filter;
    public MotionBlur blur;
    public Image retina;

    //Variables of Condition
    float blurAmount = 0.1f;
    float shakeAmount = 0.01f;
    float noiseIntensity = 1f;

    float currentShakeAmount;

    //Tips
    public TipsGenerator Tip;

    //Damage System - Death
    public GameObject playerBody;//This is for controlling the crouching and using it to simulate death
    public GameObject playerCamera;
    CharacterController body;

    //Audio
    public AudioSource SFX_sanityEmpty;
    public AudioSource SFX_voices;
    public AudioSource SFX_cracklingSound;

    //Tools
    Vector3 cameraOriginalPos;
    public static bool isDraining;
    bool passOutOnce = true;
    public static bool isPassedOut;
    float defaultFOV;

    void Awake()
    {
        sanity = 100;

        //Damage System - Death
         body = playerBody.GetComponent<CharacterController>();
        //Sanity Effects
        cameraOriginalPos = playerCamera.GetComponent<Camera>().transform.localPosition;

        //Noise
        noiseIntensity = 0;

        defaultFOV = playerCamera.GetComponent<Camera>().fieldOfView;
    }

    void sanityBarMonitor()
    {
        barFiller.GetComponent<Image>().color = currentColor;
        sanityIcon.GetComponent<Image>().color = currentColor;
        barFiller2.GetComponent<Image>().color = currentColor;
        sanityIcon2.GetComponent<Image>().color = currentColor;

        if (isDraining && !WaterInteraction.isUnderWater)
        {
            if (RenderSettings.fogDensity < 0.08f)
                RenderSettings.fogDensity += 0.0005f;
            else if(RenderSettings.fogDensity > 0.08f)
                RenderSettings.fogDensity = 0.08f;


            RenderSettings.fogColor = depletingColor;
            Debug.Log("Sanity is Bleh");
        }
        else
        {
            if (RenderSettings.fogDensity > 0.002f)
                RenderSettings.fogDensity -= 0.0005f;
            else if (RenderSettings.fogDensity < 0.002f)
            {
                RenderSettings.fogDensity = 0.002f;
                RenderSettings.fogColor = normalColor;
            }
     
        }

        if(sanity >= 100)
        {
            currentColor = c[0];
            SFX_voices.mute = true;
            filter.enabled = false;
            retina.color += new Color32(0, 0, 0, 0);
            shakeAmount = 0;
            blurAmount = 0;
            isPassedOut = false;
        }

       else if (sanity >= 90 && sanity < 100)
        {
         
            currentColor = c[0];
            SFX_voices.mute = true;
            filter.enabled = false;
            retina.color += new Color32(0, 0, 0, 6);
            shakeAmount = 0f;
            blurAmount = 0.1f;
            noiseIntensity = 0.1f;

        }
        else if (sanity < 90 && sanity >= 80)
        {
            currentColor = c[1];
            SFX_voices.mute = true;
            filter.enabled = false;
            if(isDraining)
            Tip.Show("Your sanity is draining, avoid scary things.");
            retina.color += new Color32(0, 0, 0, 12);
            shakeAmount = 0;
            blurAmount = 0.2f;
            noiseIntensity = 0.2f;
        }
        else if (sanity < 80 && sanity >= 70)
        {
            currentColor = c[2];
            SFX_voices.mute = true;
            filter.enabled = false;
            retina.color += new Color32(0, 0, 0, 18);
            shakeAmount = 0.021f;
            blurAmount = 0;
            noiseIntensity = 0.4f;
        }
        else if (sanity < 70 && sanity >= 60)
        {
            currentColor = c[3];
            SFX_voices.mute = true;
            filter.enabled = false;
            retina.color += new Color32(0, 0, 0, 24);
            shakeAmount = 0.022f;
            blurAmount = 0.5f;
            noiseIntensity = 0.6f;
        }
        else if (sanity < 60 && sanity >= 50)
        {
            currentColor = c[4];
            SFX_voices.mute = true;
            filter.enabled = false;
            if(isDraining)
            Tip.Show("Your sanity is rapidly depleting, stay away from scary things.");
            retina.color += new Color32(0, 0, 0, 30);
            shakeAmount = 0.23f;
            blurAmount = 0.55f;
            noiseIntensity = 0.8f;
        }
        else if (sanity < 50 && sanity >= 40)
        {
            currentColor = c[5];
            SFX_voices.mute = false;
            filter.enabled = true;
            retina.color += new Color32(0, 0, 0, 38);
            shakeAmount = 0.024f;
            blurAmount = 0.9f;
            noiseIntensity = 0.8f;
        }
        else if (sanity < 40 && sanity >= 30)
        {
            blur.blurAmount = 0.5f;
            currentColor = c[6];
            SFX_voices.mute = false;
            filter.enabled = true;
            retina.color += new Color32(0, 0, 0, 42);
            shakeAmount = 0.025f;
            blurAmount = 0.65f;
            noiseIntensity = 1f;
        }
        else if (sanity < 30 && sanity >= 20)
        {
            blur.blurAmount = 0.5f;
            currentColor = c[7];
            SFX_voices.mute = false;
            filter.enabled = true;
            if(isDraining)
            Tip.Show("Your sanity is dangerously low. Stay calm to reduce agitation");
            retina.color += new Color32(0, 0, 0, 48);
            shakeAmount = 0.026f;
            blurAmount = 0.7f;
            noiseIntensity = 1f;
        }
        else if (sanity < 20 && sanity >= 10)
        {
            blur.blurAmount = 0.5f;
            currentColor = c[8];
            SFX_voices.mute = false;
            filter.enabled = true;
            retina.color += new Color32(0, 0, 0, 54);
            shakeAmount = 0.027f;
            blurAmount = 0.75f;
            noiseIntensity = 1f;
        }
        else if (sanity < 10 && sanity > 0)
        {
            blur.blurAmount = 0.5f;
            currentColor = c[9];
            SFX_voices.mute = false;
            filter.enabled = true;
            retina.color += new Color32(0, 0, 0, 60);
            shakeAmount = 0.028f;
            blurAmount = 0.8f;
            noiseIntensity = 1f;
        }
        else if (sanity < 0 && sanity > -1 && passOutOnce)
        {
            passOutOnce = false;
            PassOut();
        }
    }

    void PassOut()
    {
        //Mechanics
        playerBody.GetComponent<FirstPersonController>().enabled = false;
        playerBody.GetComponent<Rigidbody>().isKinematic = false;
        playerBody.GetComponent<Rigidbody>().freezeRotation = true;
        playerCamera.transform.Rotate(0,0,15,0);
        body.enabled = false;

        //Disables
        SFX_voices.mute = true;
        filter.enabled = false;
        shakeAmount = 0.02f;

        //SFX
        SFX_sanityEmpty.Play();

        //Other
        isPassedOut = true;
    }

    void OnTriggerEnter(Collider col)
    {
        if(col.tag == "SanityDanger")
        {
            if(!isPassedOut)
            isDraining = true;
        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.tag == "SanityDanger")
        {
            if(!isPassedOut)
            isDraining = false;
        }
    }

    void drainSanity(float x)
    {
        sanity -= x*Time.deltaTime;

        //Enable blur
        if (blur.blurAmount < blurAmount)
            blur.blurAmount += 0.001f;

        //Enable crackling sound
        if (SFX_cracklingSound.volume < noiseIntensity)
            SFX_cracklingSound.volume += 0.001f;

        //Enable Shake
        if (currentShakeAmount < shakeAmount)
            currentShakeAmount += 0.001f;
        ShakeCamera(currentShakeAmount);

        //Vision throbbing effect
        ThrobCamera(true);
    }

    void restoreSanity()
    {
        //Increase Sanity
        if (sanity <= 50)
            sanity += Time.deltaTime/2;

        //Disable crackling sound
        if (SFX_cracklingSound.volume > 0)
            SFX_cracklingSound.volume -= 0.002f;
        ThrobCamera(false);

       //Disable blur
        if (blur.blurAmount > 0)
            blur.blurAmount -= 0.05f;
        else if (blur.blurAmount < 0)
            blur.blurAmount = 0;

        //Disable Shake
        if (currentShakeAmount > 0)
            currentShakeAmount -= 0.002f;
        else if (currentShakeAmount < 0.1f)
            currentShakeAmount = 0;
        ShakeCamera(currentShakeAmount);
    }

    //Effects

    void ThrobCamera(bool x)
    {
        Camera cam = playerCamera.GetComponent<Camera>();

             if (!x && cam.fieldOfView < defaultFOV)
            cam.fieldOfView += 5 * Time.deltaTime / 2;
        else if (x && cam.fieldOfView > defaultFOV - 5)
            cam.fieldOfView -= 5 * Time.deltaTime / 2;
        else if (cam.fieldOfView > defaultFOV)
            cam.fieldOfView = 50;
        else if (cam.fieldOfView < defaultFOV - 5)
            cam.fieldOfView = defaultFOV - 5;
    }

    void ShakeCamera(float x)
    {
        if(currentShakeAmount != 0)
        playerCamera.transform.localPosition = cameraOriginalPos + Random.insideUnitSphere*x;
    }

    void Update()
    {
        sanityBar.Value = sanity;
        sanityBar2.Value = sanity;
        sanityBarMonitor();

        if (isDraining || constantDepletion)
            drainSanity(2);
        else
            if (PlayerHealth.health >= 30)
            restoreSanity();

        if (PlayerHealth.health <= 30)
            blur.blurAmount = 0.5f;

        if (sanity > 100)
            sanity = 100;
    }

}

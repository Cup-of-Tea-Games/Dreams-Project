using UnityEngine;
using System.Collections;
using ProgressBar;
using UnityEngine.UI;

public class FlashlightSimple : MonoBehaviour
{
    //  public Animator animator; // Select Animation in which shall recycle the shotgun bobbing animations
    //  bool soundDelay = true; //This is to create delay toggle
    bool isOn = false;
    bool toggle; //toggler
    public GameObject spotlight; //Spotlight goes here
 //   public AudioSource clickSound; //Flashlight sounds
    public float health;


    //ProgressBar GUI Related
    public ProgressRadialBehaviour LightBar;
    public GameObject fillerBar;
    public GameObject lightIcon;
    Color32 currentColor;
    public Color32[] c;

    //Other
    public static bool isDead;
   // public TipsGenerator tips;

    void Awake()
    {
        health = 100;
        isDead = false;
    }

    void Update()
    {
     //   FlashControls();
        FlashLight_Health();
        //   lightBarMonitor();

        if (Input.GetMouseButtonDown(0) && !WeaponWheel.isShowing)
            Flashlight_On_Off();

        if (isDead)
        {
            toggle = false;
        }

        if (health > 100)
            health = 100;
    }

    void Flashlight_On_Off()
    {
        if (toggle || !toggle)
            toggle = !toggle;

        if (toggle)
        {
            if (!isDead)
            {
                spotlight.SetActive(true);
                isOn = true;
            }
            else
            {
                toggle = false;
                isOn = false;
            }
        }
        else
        {
            spotlight.SetActive(false);
            isOn = false;
        }

     //   clickSound.Play();
    }

    void FlashControls() //Handles Animations and controls for the Flashlight
    {
        //Initializes Component
        AdjustToggle();

           // if (soundDelay == true)
            {
                Inventory.animProtecter = false;
               // soundDelay = false;
                //Toggles Flashlight
                Flashlight_On_Off();
                StartCoroutine(ToggleFlash());
            }

        }
    
    public IEnumerator ToggleFlash()
    {
        yield return new WaitForSeconds(0.25f);
        StopCoroutine(ToggleFlash());
       // soundDelay = true;
        Inventory.animProtecter = true;
    }

    void AdjustToggle() //Initialize the toggle function
    {
        if (health <= 0)
            isDead = true;
    }

    void FlashLight_Health()
    {
       // LightBar.Value = health;
        if (isOn)
        {
            StartCoroutine(healthDecrease());
        }

    } //As the Flashlight is on, the health decreases of such

    public IEnumerator healthDecrease()
    {

        if (health > 0)
            health -= 0.025f;
        //    healthBar.Value = health;
        //   Debug.Log(health);
        yield return new WaitForSeconds(1f);
        StopCoroutine(healthDecrease());
    } //Rate of health decrease in the Flashlight

    void lightBarMonitor()
    {
        fillerBar.GetComponent<Image>().color = currentColor;
        lightIcon.GetComponent<Image>().color = currentColor;

        if (health > 0)
            spotlight.GetComponent<Light>().intensity = 1;

        if (health >= 100)
        {
            currentColor = c[0];
        }

        else if (health >= 90 && health < 100)
        {
            currentColor = c[0];
        }
        else if (health < 90 && health >= 80)
        {
            currentColor = c[1];
        }
        else if (health < 80 && health >= 70)
        {
            currentColor = c[2];
        }
        else if (health < 70 && health >= 60)
        {
            currentColor = c[3];
        }
        else if (health < 60 && health >= 50)
        {
            currentColor = c[4];
        }
        else if (health < 50 && health >= 40)
        {
            currentColor = c[5];
            if (isOn)
            {
             //   tips.Show("Your Flashlight's battery is draining. Find Batteries.");
                spotlight.GetComponent<Light>().intensity = 0.8f;
            }
        }
        else if (health < 40 && health >= 30)
        {
            currentColor = c[6];
            if (isOn)
                spotlight.GetComponent<Light>().intensity = 0.7f;
        }
        else if (health < 30 && health >= 20)
        {
            currentColor = c[7];
            if (isOn)
                spotlight.GetComponent<Light>().intensity = 0.6f;
        }
        else if (health < 20 && health >= 10)
        {
            currentColor = c[8];
            if (isOn)
            {
             //   tips.Show("Batteries are almost depleted, explore to find more batteries.");
                spotlight.GetComponent<Light>().intensity = 0.5f;
            }

        }
        else if (health < 10 && health > 0)
        {
            currentColor = c[9];
            if (isOn)
                spotlight.GetComponent<Light>().intensity = 0.4f;
        }
        else if (health <= 0)
        {
            if (isOn)
                spotlight.GetComponent<Light>().intensity -= Time.deltaTime;

          //  if (!isDead)
            //    tips.Show("Battery is dead. Find Batteries.");

            isDead = true;
            Flashlight_On_Off();
            toggle = false;
        }
        if (health > 0 || spotlight.GetComponent<Light>().intensity <= 0)
            isDead = false;

    }

}

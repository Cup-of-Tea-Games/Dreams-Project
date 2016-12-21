using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Shotgun
    : MonoBehaviour {

    public GameObject player;
    public Animator anim;
    public AudioSource gunShotSound;
    bool soundDelay; //This is to create delay for the shot 
    public static int ammo;
    public Text ammoNumber;

    void Awake()
    {
        Inventory.animProtecter = true;
        soundDelay = true;
        StartCoroutine(PlayShotBlast());
    }

	void Update ()
    {
        ammoCheck();

        //Check Walking Animations
           if ((Input.GetKey("w") || Input.GetKey("a") || Input.GetKey("s") || Input.GetKey("d")) && Input.GetButton("Fire1"))
        {
            if (soundDelay == true)
            {
                anim.speed = 1;
                if (ammo > 0)
                    Fire();
            }
        }
        else if (Input.GetKey("w") || Input.GetKey("a") || Input.GetKey("s") || Input.GetKey("d") && !Input.GetButton("Fire1"))
        {
            if (!Input.GetKey(KeyCode.LeftShift))
                anim.speed = 0.625f;
            else
                anim.speed = 1;
            anim.Play("Walk");
        }
        else if (!(Input.GetKey("w") || Input.GetKey("a") || Input.GetKey("s") || Input.GetKey("d")) && Input.GetButton("Fire1")) {
            if (soundDelay == true)
            {
                anim.speed = 1;
                if (ammo > 0)
                Fire();
            }

        }
    }

    public IEnumerator PlayShotBlast() {
        if (!soundDelay)
        yield return new WaitForSeconds(0.75f);
        soundDelay = true;
        Inventory.animProtecter = true;
        StopCoroutine(PlayShotBlast());
    }

    void Fire()
    {
        Inventory.animProtecter = false;
        soundDelay = false;
        anim.Play("Fire");
        gunShotSound.Play();
        FireRound.activate = true;
        ammo -= 1;
        StartCoroutine(PlayShotBlast());
    }

    bool isGrounded()
    {
     //   GameObject player = GameObject.Find("Player");

        if (player.GetComponent<Rigidbody>().velocity.y >= -0.9 && player.GetComponent<Rigidbody>().velocity.y <= 0.9)
            return true;
        else
            return false;
    }

    void ammoCheck()
    {
        ammoNumber.text = "" + ammo;
        if (ammo > 4)
            ammoNumber.color = Color.white;
        else
            ammoNumber.color = Color.red;

    }
}

using UnityEngine;
using System.Collections;

public class ObjectStabilizer : MonoBehaviour {

    private AudioSource sound;
    public bool DoesItHaveSound;
    public bool isAudioSeperated;
    public AudioClip normalImpact;
    public AudioClip heavyImpact;
    bool isColliding = false;

    void Awake()
    {

        if (DoesItHaveSound)
                sound = GetComponent<AudioSource>();

    }

    void Update()
    {

        //Stabilizing Object during pick up
        if (!Raycast_Pickup.isLooking)
        {
            gameObject.GetComponent<Rigidbody>().useGravity = true;
            gameObject.GetComponent<Rigidbody>().freezeRotation = false;
        }

        if (Raycast_Pickup.isGrabbing && gameObject == Raycast_Pickup.objectInstance)
            gameObject.GetComponent<SphereCollider>().enabled = true;
        else
            gameObject.GetComponent<SphereCollider>().enabled = false;

    }

    //Handles the noises in which shall be made during collision
    void OnCollisionEnter(Collision collision)
    {
        isColliding = true;

        foreach (ContactPoint contact in collision.contacts)
        {
            Debug.DrawRay(contact.point, contact.normal, Color.white);
        }


        if (collision.relativeVelocity.magnitude > 3 && collision.relativeVelocity.magnitude < 10 && DoesItHaveSound)
        {
            sound.clip = normalImpact;
            sound.pitch = 1.0f;
            sound.Play();
        }

        else if (collision.relativeVelocity.magnitude > 10 && DoesItHaveSound)
        {
            if (isAudioSeperated)
            {
                sound.clip = heavyImpact;
                sound.pitch = 1.0f;
                sound.Play();
            }

        else
            {
                sound.clip = normalImpact;
                sound.pitch = 0.75f;
                sound.Play();
            }
        }
        

    }

    void OnCollisionExit(Collision collision)
    {
        isColliding = false;

    }


    public bool isOnCollision()
    {
        return isColliding;
    }

}

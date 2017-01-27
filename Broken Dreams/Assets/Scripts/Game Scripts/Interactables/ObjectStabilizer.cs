using UnityEngine;
using System.Collections;

public class ObjectStabilizer : MonoBehaviour {

    private AudioSource sound;
    public bool DoesItHaveSound;
    public bool isAudioSeperated;
    public AudioClip normalImpact;
    public AudioClip heavyImpact;
    bool isColliding = false;
    public float grabOffset = 0;
    public float radiusMultiplier = 3;
  //  public bool canBreak = false;
  //  public GameObject breakableItem;
 //   public float cutPieces;
   // public float piecesSize;

    float increasedRadius;
    float defaultRadius;

    void Awake()
    {

        if (DoesItHaveSound)
                sound = GetComponent<AudioSource>();

        defaultRadius = GetComponent<SphereCollider>().radius;
        increasedRadius = defaultRadius * radiusMultiplier;

    }

    void Update()
    {
        //Stabilizing Object during pick up
        if (!Raycast_Pickup.isLooking)
        {
            gameObject.GetComponent<Rigidbody>().freezeRotation = false;
        }

        if (Raycast_Pickup.isGrabbing && gameObject == Raycast_Pickup.objectInstance)
        {
            gameObject.GetComponent<SphereCollider>().enabled = true;
            GetComponent<SphereCollider>().radius = increasedRadius;
            GetComponent<Rigidbody>().velocity = new Vector3(0,0,0);
        }
        else
        {
            gameObject.GetComponent<SphereCollider>().enabled = false;
            GetComponent<SphereCollider>().radius = defaultRadius;
        }

    }

    //Handles the noises in which shall be made during collision
    void OnCollisionEnter(Collision collision)
    {
        isColliding = true;

        foreach (ContactPoint contact in collision.contacts)
        {
            Debug.DrawRay(contact.point, contact.normal, Color.white);
        }


      /*  if(collision.relativeVelocity.magnitude > 10 && canBreak)
        {
            breakableItem.AddComponent<MeshBreak>();
            breakableItem.GetComponent<MeshBreak>().piecesSize = piecesSize;
            breakableItem.GetComponent<MeshBreak>().cutRate = cutPieces;
            StartCoroutine(breakableItem.GetComponent<MeshBreak>().SplitMesh(true));
        } */


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


        if (collision.gameObject.tag == "Player")
          {
            Physics.IgnoreCollision(collision.collider, GetComponent<Collider>());
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

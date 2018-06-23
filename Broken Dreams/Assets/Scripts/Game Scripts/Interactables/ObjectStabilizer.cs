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
    float pitchVar = 1;
    public float pitchMultiplier = 1;
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

        sound.mute = true;

        StartCoroutine(muteAwake(3));

        if (GetComponent<SphereCollider>() != null)
        defaultRadius = GetComponent<SphereCollider>().radius;
        increasedRadius = defaultRadius * radiusMultiplier;

        gameObject.layer = 13;
        foreach (Transform child in gameObject.transform)
        {
            child.gameObject.layer = 13;
        }
    }

    void Update()
    {


        //Stabilizing Object during pick up
        if (!Raycast_Pickup.isLooking)
        {
            gameObject.GetComponent<Rigidbody>().freezeRotation = false;
        }

        if (Raycast_Pickup.isGrabbing && Raycast_Pickup.objectInstance == Raycast_Pickup.pickUpInstance)
        {
            gameObject.GetComponent<SphereCollider>().enabled = true;
            GetComponent<SphereCollider>().radius = increasedRadius;
            GetComponent<Rigidbody>().velocity = new Vector3(0,0,0);
     //       Debug.Log("TRUEEEEEEEEEEEEE");
        }
        else
        {
            if (gameObject.GetComponent<SphereCollider>() != null)
            {
                gameObject.GetComponent<SphereCollider>().enabled = false;
                GetComponent<SphereCollider>().radius = defaultRadius;
            }
        //    Debug.Log("FALSEEEEEEEEEE");
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


        if (collision.relativeVelocity.magnitude > 2 && collision.relativeVelocity.magnitude < 10 && DoesItHaveSound)
        {
            sound.clip = normalImpact;
            sound.pitch = 1.0f*pitchVar*pitchMultiplier;
            sound.Play();
            changePitch();
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
                sound.pitch = 0.75f*pitchVar*pitchMultiplier;
                sound.Play();
                changePitch();
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

    void changePitch()
    {
        float[] pitchValue = {1.0f,1.1f,0.9f,1.15f,0.95f};
        pitchVar = pitchValue[Random.RandomRange(0,5)];
    }

    private IEnumerator muteAwake(int x)
    {
        sound.mute = true;
        yield return new WaitForSeconds(x);
        sound.mute = false;
        StopCoroutine(muteAwake(x));
    }

}

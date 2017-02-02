using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class SitDown : MonoBehaviour
{

    public GameObject player;
    public static bool canSitDown = false;
    public static bool sitDown = false;
    public static bool isSatDown = false;
    bool getOut = false;
    bool resetActivator = true;

    public GameObject leatherChair;
    public GameObject leatherChair_Trigger;
    public GameObject leatherChair_Position;
    public GameObject leatherChair_ExitPosition;
    public GameObject couch;
    public GameObject couch_Trigger;
    public GameObject couch_Position;
    public GameObject officeChair;
    public GameObject officeChair_Trigger;
    public GameObject officeChair_Position;
    public GameObject bed;
    public GameObject bed_Trigger;
    public GameObject bed_Position;

    void OnTriggerEnter(Collider col)
    {
        if (col.tag == "Sit Area")
        {
            canSitDown = true;
        }
        else
        {
            canSitDown = false;
        }
    }

    void Update()
    {
        if (sitDown)
        {
            if (Raycast_Pickup.objectInstance == leatherChair)
            {
                if(!isSatDown)
                StartCoroutine(enter());
            

            if (Input.GetKeyDown(KeyCode.Space))
            {
                getOut = true;
                sitDown = false;
                isSatDown = false;
            }
        }
        }

            if (getOut)
            {
            StartCoroutine(exit());
            }


            }




    private IEnumerator exit()
    {
        player.transform.position = Vector3.Slerp(player.transform.position, leatherChair_ExitPosition.transform.position, 5f * Time.deltaTime);
        yield return new WaitForSeconds(0.8f);
        player.GetComponent<CharacterController>().detectCollisions = true;
        player.GetComponent<Rigidbody>().detectCollisions = true;
        resetActivator = true;
        getOut = false;
    }

    private IEnumerator enter()
    {
        player.GetComponent<CharacterController>().detectCollisions = false;
        player.GetComponent<Rigidbody>().detectCollisions = false;
        player.GetComponent<FirstPersonController>().enabled = false;
        player.transform.position = Vector3.Slerp(player.transform.position, leatherChair_Position.transform.position, 5f * Time.deltaTime);
        player.transform.rotation = Quaternion.Slerp(player.transform.rotation, leatherChair_Position.transform.rotation, 4f * Time.deltaTime);
        yield return new WaitForSeconds(0.9f);
        isSatDown = true;
        if (resetActivator)
        {
            StartCoroutine(player.GetComponent<FirstPersonController>().mouseLookReset());
            resetActivator = false;
        }
        player.GetComponent<FirstPersonController>().enabled = true;
        StopCoroutine(enter());
    }

}

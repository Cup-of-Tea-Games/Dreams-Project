using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class SitDown : MonoBehaviour {

    public GameObject player;
    public static bool canSitDown = false;
    public static bool sitDown = false;
    public static bool isSatDown = false;

    public GameObject leatherChair;
    public GameObject leatherChair_Trigger;
    public GameObject leatherChair_Position;
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
        if(col.tag == "Sit Area")
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
        if(sitDown)
        {
            if (Raycast_Pickup.objectInstance == leatherChair)
            {
                if (player.transform.position != leatherChair_Position.transform.position)
                {
                    player.GetComponent<FirstPersonController>().enabled = false;
                    player.transform.position = Vector3.Slerp(player.transform.position, leatherChair_Position.transform.position, 5f * Time.deltaTime);
                    player.transform.rotation = Quaternion.Slerp(player.transform.rotation, leatherChair_Position.transform.rotation, 3f * Time.deltaTime);
                }
                else
                {
                    player.GetComponent<FirstPersonController>().enabled = true;
                    sitDown = false;
                    isSatDown = true;
                }

            }
        }
    }
}

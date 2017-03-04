using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Bed : MonoBehaviour {

    public Animator anim;
    public GameObject player;
    public GameObject unarmed;
    public bool canSitDown = false;
    public static bool sitDown = false;
    public bool exit = false;
    public static bool isSatDown = false;
    public bool satDown;

    public GameObject bed;
    public GameObject bed_Position;

    void Awake()
    {
        anim.Play("Get_Out");
    }

    void Update()
    {

        if (exit)
        {
            exitBed();
        }

        satDown = isSatDown;
        // Debug.Log("SitDown : " + sitDown + " CanSitDown : " + canSitDown + " isSatDown : " + isSatDown);

        if (Raycast_Pickup.chairInstance == bed)
        {
            canSitDown = true;
        }
        else
        {
            canSitDown = false;
        }

        if (sitDown)
        {

            if (Raycast_Pickup.chairInstance == bed)
            {
                if (!isSatDown)
                    StartCoroutine(enter());

            }
        }


    }

    public void exitBed()
    {
        exit = false;
        anim.enabled = false;
        player.GetComponent<FirstPersonController>().enabled = true;
        unarmed.SetActive(true);
    }

    private IEnumerator enter()
    {
        unarmed.SetActive(false);
        player.GetComponent<CharacterController>().detectCollisions = false;
        player.GetComponent<Rigidbody>().detectCollisions = false;
        player.GetComponent<FirstPersonController>().enabled = false;
        player.transform.position = Vector3.Slerp(player.transform.position, bed_Position.transform.position, 5f * Time.deltaTime);
        player.transform.rotation = Quaternion.Slerp(player.transform.rotation, bed_Position.transform.rotation, 4f * Time.deltaTime);
        yield return new WaitForSeconds(1f);
        anim.enabled = true;
        anim.Play("Lay_In_Bed");
    }

}

using UnityEngine;
using System.Collections;

public class Vaulter : MonoBehaviour
{


    public float ClimbMax;
    public float VaultMax;
    public float VaultMin;
    public float distanceToGoFwd = 0.7f;
    private bool CanVault;
    private bool CanClimb;
    private float DistancePlRayFwd;
    private float DistancePlRayUp;
    public string VaultAnim;
    public string ClimbAnim;
    public GameObject cam;
    public Transform Player;
    public CharacterController charCont;
    private bool CanParkour;
    bool EnableRoll;
    float lastPos;
    private float max;
    public GameObject CheckRay;
    public float range;
    private float maxH;
    bool Translate;


    void Update()
    {
        if (CanParkour || charCont.isGrounded == false)
            Translate = true;
        else
            Translate = false;
        maxH = Mathf.Abs(max - Player.transform.position.y + charCont.height / 2);
        //   Debug.Log("Can Climb " + CanClimb + " CanVault " + CanVault);
        Debug.Log("Can Parkour " + CanParkour);
        var radius = charCont.radius;
        // find centers of the top/bottom hemispheres
        Vector3 p1 = transform.position + charCont.center;
        var p2 = p1;
        p2.y += VaultMax;
        p1.y -= charCont.height / 2 + 0.02f;
        if (Physics.CapsuleCast(p1, p2, radius, transform.forward, range))
        {
            if (!Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), 0.7f))
            {
                if (!CanParkour)
                {
                    if (Input.GetKeyDown(KeyCode.V))
                    {
                        Player.transform.position = new Vector3(Player.transform.position.x, CheckRay.transform.position.y + charCont.height + 0.1f, Player.transform.position.z);
                        Player.transform.Translate(0, 0, distanceToGoFwd + 0.3f);
                        GetComponent<Animator>().Play(VaultAnim);
                        //Arms.animation.Play(VaultArms);
                    }
                }
            }
            if (Physics.Raycast(CheckRay.transform.position, transform.TransformDirection(Vector3.forward), 0.7f))
            {
                CheckRay.transform.Translate(0, 8 * Time.deltaTime, 0);
                max = Mathf.Max(max, CheckRay.transform.position.y);
            }
            if (maxH < ClimbMax)
            {
                Changing();
            }
            else
                CanParkour = false;
            if (maxH >= VaultMax)
            {
                CanVault = false;
                CanClimb = true;
            }
            else
            {
                CanVault = true;
                CanClimb = false;
            }
        }
        else
        {
            CanParkour = false;
            max = 0;
            CheckRay.transform.position = new Vector3(CheckRay.transform.position.x, Player.transform.position.y, CheckRay.transform.position.z);
        }
        if (CanParkour)
        {
            if (CanVault == true)
            {
                Debug.Log("EEEEEEEEEEEEEEEE");
                if (Input.GetKeyDown(KeyCode.V))
                {
                    Debug.Log("EEEEEEEEEEEEEEEE");
                    Vault();
                }
            }
            if (CanClimb == true)
            {
                if (Input.GetKeyDown(KeyCode.V))
                {
                    Debug.Log("EEEEEEEEEEEEEEEEEEEEEEE");
                    Climb();
                }
            }
        }
        if (EnableRoll)
        {
            //   if (!charCont.isGrounded)
            //       maxFall = Mathf.Max(Mathf.Abs(charCont.transform.position.y), maxFall);
            //   else
            //       lastPos = charCont.transform.position.y;
            //  if (charCont.isGrounded)
            {
                //  if (maxFall - lastPos > HeightToRoll)
                {
                    //    cam.animation.Play(Roll);
                    //Arms.animation.Play(RollArms);
                    //  if (maxFall - lastPos > distanceDamage)
                    {
                        //    Player.transform.SendMessageUpwards("GetBulletDamage", maxFall + distanceDamage * 2, SendMessageOptions.DontRequireReceiver);
                    }
                    //  maxFall = 0;
                }
            }
        }
    }

    public IEnumerator Vault()
    {
        Debug.Log("WOOOOOOOOOOOP");
        var upDist = CheckRay.transform.position.y + 0.2f;
        var fwdDist = distanceToGoFwd;
        GetComponent<Animator>().Play(VaultAnim);
        Vector3 endPos = new Vector3(Player.transform.position.x, upDist, fwdDist);
        Player.transform.position = Vector3.MoveTowards(Player.transform.position, endPos, 5 * Time.deltaTime);
        yield return new WaitForSeconds(distanceToGoFwd);
        Translate = false;
    }

    void Climb()
    {
        Debug.Log("WOOOOOOOOOOOP");
        Player.transform.position = new Vector3(Player.transform.position.x, CheckRay.transform.position.y + charCont.height + 5f, Player.transform.position.z);
        Player.transform.position = Vector3.back * (distanceToGoFwd + 5f);
        // GetComponent<Animator>().Play(ClimbAnim);
        Translate = false;
    }

    public IEnumerator Changing()
    {
        yield return new WaitForSeconds(0.3f);
        CanParkour = true;
    }
}

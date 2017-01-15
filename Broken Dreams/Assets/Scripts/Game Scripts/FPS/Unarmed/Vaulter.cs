using UnityEngine;
using System.Collections;
using UnityStandardAssets.Utility;

public class Vaulter : MonoBehaviour
{


    public static bool isVaulting = false;
    private bool CanVault;
    public GameObject cam;
    public GameObject Player;
    public CharacterController charCont;
    private bool CanParkour;
    bool EnableRoll;
    float lastPos;
    private float max;
    public GameObject CheckRayHead;
    public GameObject CheckRayBody;
    public GameObject HookSystem;
    public Transform Vertical_Destination;
    public Transform Horizontal_Destination;

    public float range;
    private float maxH;
    bool Translate;

    void Update()
    {
        if (Physics.Raycast(CheckRayBody.transform.position, transform.TransformDirection(Vector3.forward), 0.7f) && !Physics.Raycast(CheckRayHead.transform.position, transform.TransformDirection(Vector3.forward), 0.7f))
        {
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    isVaulting = true;
                    Vault();
                }
        }

    }

    public void Vault()
    {
        HookSystem.GetComponent<FollowTarget>().enabled = false;
   
    }

    public void recoverHook()
    {
        HookSystem.SetActive(false);
        HookSystem.transform.position = Player.transform.position;
        HookSystem.SetActive(true);
        HookSystem.GetComponent<FollowTarget>().enabled = true;
    }

    public IEnumerator Changing()
    {
        yield return new WaitForSeconds(0.3f);
        CanParkour = true;
    }
}

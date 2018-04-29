using UnityEngine;
using System.Collections;

public class KeyReciever : MonoBehaviour {

    public bool isAnimationBased = false;
    public bool isColliderBased = false;
    public GameObject spawnPlacementObject;
    public string tagName;
    bool active = false;
    TipsGenerator tips;
    public string successMessage;
    public string failedMessage;
    public string investigateMessage;

    //SFX
    public AudioSource recieveSFX;

    void Awake()
    {
        tips = GameObject.Find("ItemTips").GetComponent<TipsGenerator>();
    }

    void Update()
    {
        if(spawnPlacementObject != null)
        active = spawnPlacementObject.activeSelf;
        if(!isColliderBased)
        GetComponent<Collider>().enabled = !active;
    }

    public void insertKey(string s)
    {
        if (s == tagName)
        {
            active = true;
            if(!isAnimationBased && !isColliderBased)
            spawnPlacementObject.SetActive(true);
            else if (isAnimationBased)
            {
              Animator anim = GetComponent<Animator>();
                anim.Play("Active");
            }
            else if (isColliderBased)
            {
                spawnPlacementObject.GetComponent<Collider>().enabled = true;
                DestroyComponent.Destroy(this.GetComponent<KeyReciever>());
                GetComponent<Collider>().enabled = false;
            }
            recieveSFX.Play();
            tips.Show(successMessage);
          //  Destroy(GetComponent<Collider>());
        }
        else
        {
            tips.Show(failedMessage);
        }
    }

    public void insertWeapon (string s)
    {
        if (s == tagName)
        {
            active = true;
            spawnPlacementObject.SetActive(true);
            tips.Show(successMessage);
            GetComponent<Collider>().enabled = false;
        }
        else
        {
            tips.Show(failedMessage);
        }
    }

    public bool isRecieved()
    {
        return active;
    }

    public void investigate()
    {
        tips.Show(investigateMessage);
    }

   // IEnumerator 
}

using UnityEngine;
using System.Collections;

public class KeyReciever : MonoBehaviour {

    public GameObject spawnPlacementObject;
    public string tagName;
    bool active = false;
    TipsGenerator tips;
    public string successMessage;
    public string failedMessage;
    public string investigateMessage;

    void Awake()
    {
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();
    }

    void Update()
    {
        active = spawnPlacementObject.activeSelf;
        GetComponent<Collider>().enabled = !active;
    }

    public void insertKey(string s)
    {
        if (s == tagName)
        {
            active = true;
            spawnPlacementObject.SetActive(true);
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

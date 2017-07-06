using UnityEngine;
using System.Collections;

public class KeyReciever : MonoBehaviour {

    public GameObject spawnPlacementObject;
    public string tagName;
    bool active = false;
    public TipsGenerator tips;
    public string successMessage;
    public string failedMessage;
    public string investigateMessage;

    public void insertKey(string s)
    {
        if (s == tagName)
        {
            active = true;
            spawnPlacementObject.SetActive(true);
            tips.Show(successMessage);
            Destroy(GetComponent<Collider>());
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
}

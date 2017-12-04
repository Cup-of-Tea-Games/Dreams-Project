using UnityEngine;
using System.Collections;

public class ProxyTrigger : MonoBehaviour {

    public GameObject gameThing;
    public string tagName;
    public bool destroyInsteadOfSpawn = false;

    void OnTriggerEnter(Collider col)
    {
        if(col.tag == tagName)
        {
            if (!destroyInsteadOfSpawn)
            {
                gameThing.SetActive(true);
            }
            else
            {
                // gameThing.SetActive(false);
                Destroy(gameThing);
            }
            Destroy(gameObject);
        }
    }
}

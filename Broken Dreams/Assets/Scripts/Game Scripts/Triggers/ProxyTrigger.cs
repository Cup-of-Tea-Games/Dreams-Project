using UnityEngine;
using System.Collections;

public class ProxyTrigger : MonoBehaviour {

    public GameObject gameThing;
    public string tagName;
    public bool destroyInsteadOfSpawn = false;
    public bool triggerButton = false;
    public Button button;

    void OnTriggerEnter(Collider col)
    {
        if(col.tag == tagName && !triggerButton)
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

        if (col.tag == tagName && triggerButton)
        {
            button.active = !button.active;
            Destroy(gameObject);
        }
    }
}

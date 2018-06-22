using UnityEngine;
using System.Collections;

public class ProxyTrigger : MonoBehaviour {

    public GameObject gameThing;
    public string tagName;
    public bool oneTimeUse = true;
    public bool invertFunction = false;
    public bool forwardsBackwards = false;
    public bool destroyInsteadOfSpawn = false;
    public bool triggerButton = false;
    public Button button;

    void OnTriggerEnter(Collider col)
    {
        if (!invertFunction)
        {
            if (col.tag == tagName && !triggerButton)
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
                if(oneTimeUse)
                Destroy(gameObject);
            }
            else if (forwardsBackwards)
            {
                if (!destroyInsteadOfSpawn)
                {
                    gameThing.SetActive(false);
                }
            }
        }

        else if (invertFunction)
        {
            if (col.tag == tagName && !triggerButton)
            {
                if (!destroyInsteadOfSpawn)
                {
                    gameThing.SetActive(false);
                }
                else
                {
                    // gameThing.SetActive(false);
                    Destroy(gameThing);
                }
                if (oneTimeUse)
                    Destroy(gameObject);
            }
            else if (forwardsBackwards)
            {
                if (!destroyInsteadOfSpawn)
                {
                    gameThing.SetActive(true);
                }
            }
        }

        if (col.tag == tagName && triggerButton)
        {
            button.active = !button.active;
            Destroy(gameObject);
        }
    }
}

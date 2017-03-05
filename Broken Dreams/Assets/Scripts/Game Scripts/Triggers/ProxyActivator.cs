using UnityEngine;
using System.Collections;

public class ProxyActivator : MonoBehaviour {

    public GameObject activatedObject;
    public bool isDoorType = false;
    public Door door;

    void OnTriggerEnter(Collider col)
    {
    if(col.tag == "Player" && !isDoorType)
        {
            activatedObject.SetActive(true);
        }

    }

    void OnTriggerExit(Collider col)
    {
        if (col.tag == "Player" && !isDoorType)
        {
            activatedObject.SetActive(false);
        }

    }

    void Update()
    {
        if (isDoorType)
         {
         if(door.GetComponent<HingeJoint>().angle > 45)
            {
                activatedObject.SetActive(true);
            }
         else
            {
                activatedObject.SetActive(false);
            }
        }
    }

}

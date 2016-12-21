using UnityEngine;
using System.Collections;

public class DestroyTrigger : MonoBehaviour {

    public GameObject ObjectToDestroy;

    void Awake()
    {
        ObjectToDestroy.SetActive(true);
    }
    void OnTriggerEnter(Collider col)
    {
        if (col.gameObject.tag == "Player")
        {
            Debug.Log("Object Destroyed");
            ObjectToDestroy.SetActive(false);
        }
    }
}

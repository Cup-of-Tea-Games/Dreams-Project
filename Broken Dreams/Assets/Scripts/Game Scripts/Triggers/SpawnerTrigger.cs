using UnityEngine;
using System.Collections;

public class SpawnerTrigger : MonoBehaviour {

    public Transform ItemSpawnLocation;
    public GameObject ObjectToAppear;
    public GameObject ItemToAppear;

    void Awake()
    {
        ObjectToAppear.SetActive(false);
        ItemToAppear.SetActive(false);
    }
    void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.tag == "Player")
        {
            Debug.Log("Item Instantiated");
            ObjectToAppear.SetActive(true);
            ItemToAppear.SetActive(true);

        }
    }
}

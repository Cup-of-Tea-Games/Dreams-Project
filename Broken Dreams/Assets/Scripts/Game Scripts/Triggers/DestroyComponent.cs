using UnityEngine;
using System.Collections;

public class DestroyComponent : MonoBehaviour {

    public bool active = false;
	
	// Update is called once per frame
	void Update () {
        if (active)
        {
            Destroy(gameObject.GetComponent<Animator>());
            Destroy(gameObject.GetComponent<DestroyComponent>());
        }
	}
}

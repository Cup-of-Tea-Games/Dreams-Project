using UnityEngine;
using System.Collections;

public class ObjRecieveDamage : MonoBehaviour {

	void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.name == "Close BlastRange")
        {
            
        }

        if (col.gameObject.name == "Long BlastRange")
        {

        }

    }
}

using UnityEngine;
using System.Collections;

public class TipsArea : MonoBehaviour {

    public TipsGenerator tips;
    public string tipText;
    public bool autoDestroySelf;

    void OnTriggerEnter(Collider col)
    {
        if(col.tag == "Player")
        {
            tips.Show(tipText);
        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.tag == "Player")
        {
           if(autoDestroySelf)
            Destroy(gameObject);
        }
    }
}

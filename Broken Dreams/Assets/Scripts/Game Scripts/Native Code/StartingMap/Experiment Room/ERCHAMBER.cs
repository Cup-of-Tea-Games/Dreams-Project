using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ERCHAMBER : MonoBehaviour {

    public ERPC PC;
    public Button hyperDoor;
    public Animator anim;
    public Wanderer wanderer;
    bool active = true;

    void Update()
    {
        if(active && PC.reroutedPower())
        {
            active = false;
            StartCoroutine(letGoWanderer());
        }
    }

    IEnumerator letGoWanderer()
    {
        PC.rerouting_SCRN.SetActive(true);
        yield return new WaitForSeconds(3f);
        PC.rerouted_SCRN.SetActive(true);
        yield return new WaitForSeconds(3f);
        hyperDoor.isLocked = false;
        anim.Play("JumpDown");
        yield return new WaitForSeconds(1.5f);
        Destroy(anim.gameObject);
        wanderer.gameObject.SetActive(true);
    }

}

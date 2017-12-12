using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ERCHAMBER : MonoBehaviour {

    public ERPC PC;
    public Button hyperDoorButton1;
    public Button hyperDoorButton2;
    public Button hyperDoorButton3;
    public Button hyperDoorButton4;
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
        hyperDoorButton1.isLocked = false;
        hyperDoorButton2.isLocked = false;
        hyperDoorButton3.hasPower = true;
        hyperDoorButton4.hasPower = true;
        hyperDoorButton3.active = true;
        anim.Play("JumpDown");
        yield return new WaitForSeconds(1.5f);
        Destroy(anim.gameObject);
        wanderer.gameObject.SetActive(true);
    }

}

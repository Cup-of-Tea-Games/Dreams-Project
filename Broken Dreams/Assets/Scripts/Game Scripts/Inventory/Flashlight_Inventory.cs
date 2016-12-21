using UnityEngine;
using System.Collections;

public class Flashlight_Inventory : MonoBehaviour{

    public Flashlight FlashLightObject;
    bool flashlightToggle;

    void Update()
    {
        if (Input.GetKey(KeyCode.F) && timeStep)
        {
            flashlightToggle = !flashlightToggle;
            activateFlashLight();
            WaitSeconds(1f);
        }

    }
    void activateFlashLight()
    {

    }


    //TimeMan 

    bool timeStep = true;

    private IEnumerator yieldSeconds(float x)
    {
        Debug.Log("Waiting :" + x + " Seconds");
        yield return new WaitForSeconds(x);
        timeStep = true;
        StopCoroutine(yieldSeconds((x)));
    }

    public void WaitSeconds(float f)
    {
        if (timeStep)
        {
            timeStep = false;
            StartCoroutine(yieldSeconds(f));
        }
    }
}

using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class WaterInteraction : MonoBehaviour
{

    public static GameObject waterInstance;

    public static bool isOnLightWater = false;
    public static bool isOnDeepWater = false;
    public static bool isOnWater = false;
    public static bool isUnderWater = false;
    public static bool isSemiUnderWater = false;
    public Color normalColor;
    public Color underWaterColor;

    public GameObject playerHead;

    void Update()
    {

        if (isOnWater)
        {
            if (playerHead.transform.position.y < waterInstance.transform.position.y)
                isUnderWater = true;
            else
                isUnderWater = false;
        }

        if (isOnDeepWater)
        {

            if (gameObject.transform.position.y + 0.5f < waterInstance.transform.position.y)
                isSemiUnderWater = true;
            else
                isSemiUnderWater = false;
        }
        

        if(isUnderWater)
        {
            RenderSettings.fogDensity = 0.03f;
            RenderSettings.fogColor = underWaterColor;
        }
        else
        {
            RenderSettings.fogDensity = 0.002f;
            RenderSettings.fogColor = normalColor;
        }


        if (isOnDeepWater || isOnLightWater)
            isOnWater = true;
        else
            isOnWater = false;

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Water")
        {
            waterInstance = other.gameObject;
            isOnLightWater = true;
        }
        else if (other.tag == "Deep Water")
        {
            waterInstance = other.gameObject;
            isOnDeepWater = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Water")
        {
            isOnLightWater = false;
        }
        else if (other.tag == "Deep Water")
        {
            isOnDeepWater = false;
        }
    }
}
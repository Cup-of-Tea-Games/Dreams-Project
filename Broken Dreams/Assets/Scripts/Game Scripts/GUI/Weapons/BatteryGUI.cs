using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class BatteryGUI : MonoBehaviour
{

    public Text textComponent;
    public Flashlight flashlight;

    // Update is called once per frame
    void Update()
    {
        textComponent.text = ((int)flashlight.getHealth() + " | " + flashlight.getBatteries());
    }
}

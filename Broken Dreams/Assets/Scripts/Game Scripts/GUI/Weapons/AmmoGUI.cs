using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class AmmoGUI : MonoBehaviour {

    public Text textComponent;
    public Handgun handgun;

	// Update is called once per frame
	void Update () {
        textComponent.text = (handgun.getAmmo() + " | " + handgun.getReserveAmmo());
	}
}

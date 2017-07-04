using UnityEngine;
using System.Collections;

public class WeaponCrosshairHudSelector : MonoBehaviour {

    public GameObject[] weapon;
    public GameObject[] crosshair;
    public GameObject[] HUD;
    bool temp;

    void Update()
    {
        //      Condition               True Statement                    False Statement
        if (weapon[0].activeSelf && weapon[0] != null) { crosshair[0].SetActive(true); HUD[0].SetActive(true); } else { crosshair[0].SetActive(false); HUD[0].SetActive(false); }
        if (weapon[1].activeSelf && weapon[1] != null) { crosshair[1].SetActive(true); HUD[1].SetActive(true); } else { crosshair[1].SetActive(false); HUD[1].SetActive(false); }
        if (weapon[2].activeSelf && weapon[2] != null) { crosshair[2].SetActive(true); HUD[2].SetActive(true); } else { crosshair[2].SetActive(false); HUD[2].SetActive(false); }
        if (weapon[3].activeSelf && weapon[3] != null) { crosshair[3].SetActive(true); HUD[3].SetActive(true); } else { crosshair[3].SetActive(false); HUD[3].SetActive(false); }
        //  if (weapon[2].activeSelf && weapon[2] != null) { crosshair[2].SetActive(true); HUD[2].SetActive(true); } else { crosshair[2].SetActive(false); HUD[2].SetActive(true); }
    }

}

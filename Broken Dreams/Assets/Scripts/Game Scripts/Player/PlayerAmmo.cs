using UnityEngine;
using System.Collections;

public class PlayerAmmo : MonoBehaviour {

    void Awake()
    {
        Shotgun.ammo = 20;
        Flashlight.health = 100;
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.tag == "Shotgun_Ammo")
        {
            Shotgun.ammo += 6;
        }
    }
}

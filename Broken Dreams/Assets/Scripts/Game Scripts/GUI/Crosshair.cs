using UnityEngine;
using System.Collections;

public class Crosshair : MonoBehaviour {

    public GameObject[] crosshair;
    public GameObject[] items;
    bool temp;

    void Update()
    { 
        //      Condition               True Statement                    False Statement
        if (items[0].activeSelf) crosshair[0].SetActive(true); else crosshair[0].SetActive(false);
     //   if (items[1].activeSelf) crosshair[1].SetActive(true); else crosshair[1].SetActive(false);
        if (items[2].activeSelf) crosshair[2].SetActive(true); else crosshair[2].SetActive(false);
    }

}

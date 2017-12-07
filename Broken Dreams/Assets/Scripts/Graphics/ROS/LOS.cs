using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LOS : MonoBehaviour {

    GameObject player;
    public Room[] rooms;
    public bool resMode;
    int qualitylevel;
    public bool parentMode = false;

    void Awake()
    {
        player = GameObject.Find("Player");
        qualitylevel = QualitySettings.GetQualityLevel();
    }

    void Update()
    {
        if (parentMode)
            parentfunc();
        else
            solofunc();
    }

    bool isInArea()
    {
        bool temp = false;
        for (int i = 0; i < rooms.Length; i++)
        {
            if (rooms[i].isColliding())
            {
                temp = true;
                break;
            }

        }
        return temp;
    }

    void parentfunc()
    {
        if (!isInArea())
        {
            for (int i = 0; (i < gameObject.GetComponentsInChildren<Transform>().Length) && (gameObject.GetComponentsInChildren<Light>() != null); i++)
            {
                if (!resMode)
                    gameObject.GetComponentsInChildren<Light>()[i].enabled = false;
                else
                {
                    gameObject.GetComponentsInChildren<Light>()[i].shadowResolution = UnityEngine.Rendering.LightShadowResolution.Low;
                }
            }
        }
        else
        {
            for (int i = 0; (i < gameObject.GetComponentsInChildren<Transform>().Length) && (gameObject.GetComponentsInChildren<Light>() != null); i++)
            {
                if (!resMode)
                    gameObject.GetComponentsInChildren<Light>()[i].enabled = true;
                else
                {
                    gameObject.GetComponentsInChildren<Light>()[i].shadowResolution = UnityEngine.Rendering.LightShadowResolution.FromQualitySettings;
                }
            }
        }
    }

    void solofunc()
    {
        if (!isInArea())
        {
                if (!resMode)
                    gameObject.GetComponent<Light>().enabled = false;
                else
                {
                    gameObject.GetComponent<Light>().shadowResolution = UnityEngine.Rendering.LightShadowResolution.Low;
                //    gameObject.GetComponent<Light>().shadows = LightShadows.None;
            }          
        }
        else
        {
            if (!resMode)
                gameObject.GetComponent<Light>().enabled = true;
            else
            {
                gameObject.GetComponent<Light>().shadowResolution = UnityEngine.Rendering.LightShadowResolution.FromQualitySettings;
             //   gameObject.GetComponent<Light>().shadows = LightShadows.Soft;
            }
        }
    }

}

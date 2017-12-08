using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MOS : MonoBehaviour
{

    GameObject player;
    public Room[] rooms;
    public bool resMode;
    int qualitylevel;
    public bool parentMode = false;
    Vector2 originalScale;

    void Awake()
    {
        player = GameObject.Find("Player");
        qualitylevel = QualitySettings.GetQualityLevel();
        originalScale = gameObject.GetComponent<Material>().mainTextureScale;
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
             //   if (!resMode)
                 //   gameObject.GetComponentsInChildren<Material>()[i].
             //   else
                {
                    gameObject.GetComponentsInChildren<Material>()[i].mainTextureScale /= 2;
                }
            }
        }
        else
        {
            for (int i = 0; (i < gameObject.GetComponentsInChildren<Transform>().Length) && (gameObject.GetComponentsInChildren<Light>() != null); i++)
            {
             //   if (!resMode)
             //       gameObject.GetComponentsInChildren<Light>()[i].enabled = true;
             //   else
                {
                    gameObject.GetComponentsInChildren<Material>()[i].mainTextureScale = originalScale;
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
                gameObject.GetComponent<Material>().color = Color.black;
                //    gameObject.GetComponent<Light>().shadows = LightShadows.None;
            }
        }
        else
        {
            if (!resMode)
                gameObject.GetComponent<Light>().enabled = true;
            else
            {
                gameObject.GetComponent<Material>().color = Color.white;
                //   gameObject.GetComponent<Light>().shadows = LightShadows.Soft;
            }
        }
    }

}

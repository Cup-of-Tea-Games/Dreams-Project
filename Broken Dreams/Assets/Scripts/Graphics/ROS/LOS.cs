using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LOS : MonoBehaviour {

    GameObject player;
    public Room[] rooms;
    public bool bakeMode;

    void Awake()
    {
        player = GameObject.Find("Player");
    }

    void Update()
    {

        float distance = Vector3.Distance(gameObject.transform.position, player.transform.position);

        if (!isInArea())
        {
            Transform[] temp = new Transform[gameObject.GetComponentsInChildren<Transform>().Length - 1];
            for (int i = 0; i < gameObject.GetComponentsInChildren<Transform>().Length; i++)
            {
                if (!bakeMode)
                    gameObject.GetComponentsInChildren<Light>()[i].enabled = false;
                else
                {
                    gameObject.GetComponentsInChildren<Light>()[i].shadows = LightShadows.None;
                }
            }
        }
        else
        {
            Transform[] temp = new Transform[gameObject.GetComponentsInChildren<Transform>().Length - 1];
            for (int i = 0; i < gameObject.GetComponentsInChildren<Transform>().Length; i++)
            {
                if (!bakeMode)
                    gameObject.GetComponentsInChildren<Light>()[i].enabled = true;
                else
                {
                    gameObject.GetComponentsInChildren<Light>()[i].shadows = LightShadows.Soft;
                }
            }
        }



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

}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MOS : MonoBehaviour
{

    GameObject player;
    public Room[] rooms;

    void Awake()
    {
        player = GameObject.Find("Player");
    }

    void Update()
    {

        if (!isInArea())
        {
            foreach (Renderer gb in GetComponentsInChildren<Renderer>())
                if (GetComponentsInChildren<Renderer>() != null)
                {
                    gb.GetComponent<Renderer>().enabled = false;
                }
        }
        else
        {
            foreach (Renderer gb in GetComponentsInChildren<Renderer>())
                if (GetComponentsInChildren<Renderer>() != null)
                {
                    gb.GetComponent<Renderer>().enabled = true;
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

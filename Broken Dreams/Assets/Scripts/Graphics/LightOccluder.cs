using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LightOccluder : MonoBehaviour {

    //   public GameObject

    GameObject player;
    public float distanceOcclude = 3;

    void Awake()
    {
        player = GameObject.Find("Player");
    }

	void Update () {
        //   Debug.Log("CURRENT STATUS : " + gameObject.GetComponent<Renderer>().isVisible);

        //    gameObject.GetComponent<Renderer>().enabled = gameObject.GetComponent<Renderer>().isVisible;

        float distance = Vector3.Distance(gameObject.transform.position, player.transform.position);

        if (distance > distanceOcclude)
        {
            gameObject.GetComponent<Light>().enabled = false;
        }
        else
            gameObject.GetComponent<Light>().enabled = true;

    }
}

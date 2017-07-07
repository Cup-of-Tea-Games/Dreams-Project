using UnityEngine;
using System.Collections;

public class Basement : MonoBehaviour {

    public Light[] pointlights;
    public GameObject waterSpawn;
    public GameObject leaker;
    public KeyReciever pipeReciever;
    public Engine engine;

    void Awake()
    {
        for (int i = 0; i < pointlights.Length; i++)
        {
            pointlights[i].enabled = false;
        }

        leaker.SetActive(false);
        waterSpawn.SetActive(false);
    }

    void Update()
    {
        if (engine.isOnline())
        {
            //Sets the lights
            for(int i = 0;i < pointlights.Length; i++)
            {
                pointlights[i].enabled = true;
            }
            //Sets the water level
            waterSpawn.SetActive(true);
            //manages what happens with the leaking pipe
            if (!pipeReciever.isRecieved())
                leaker.SetActive(true);
            else
                leaker.SetActive(false);
        }
    }

}

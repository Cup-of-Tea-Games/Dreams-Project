using UnityEngine;
using System.Collections;

public class CellDoor : SpecialDoor {

    public Engine engine;
    public GameObject steam;

    void Awake()
    {
        steam.SetActive(false);
    }
    void Update()
    {
        if(engine.isOnline())
        if (!pipeReciever.isRecieved())
        {
            door.transform.position = Vector3.Lerp(originalPos.position,nextPos.position,Time.deltaTime*speed);
                 steam.SetActive(true);
        }
        else
        {
            door.transform.position = Vector3.Lerp(nextPos.position, originalPos.position, Time.deltaTime * speed);
                 steam.SetActive(false);
        }
    }
}

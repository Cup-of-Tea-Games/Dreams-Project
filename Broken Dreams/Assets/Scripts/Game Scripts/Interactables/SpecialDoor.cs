using UnityEngine;
using System.Collections;

public class SpecialDoor : MonoBehaviour {

    public KeyReciever pipeReciever;
    public Transform originalPos;
    public Transform nextPos;
    public GameObject door;
    public float speed;

    void Update()
    {
        if (!pipeReciever.isRecieved())
        {
            door.transform.position = Vector3.Lerp(originalPos.position,nextPos.position,Time.deltaTime*speed);
        }
        else
        {
            door.transform.position = Vector3.Lerp(nextPos.position, originalPos.position, Time.deltaTime * speed);
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloodedChamber : MonoBehaviour {

    public KeyReciever[] pipes = new KeyReciever[3];
    public BodyShreder[] shreders = new BodyShreder[4];
    public GameObject bloodPlane;
    float planeMoveValue = 0;
    public float riseSpeed;

    public bool isActive()
    {
        return (pipes[0].isRecieved() && pipes[1].isRecieved() && pipes[2].isRecieved()) 
            && (shreders[0].finishedShreding() && shreders[1].finishedShreding() && shreders[2].finishedShreding() && shreders[3].finishedShreding());
    }

    void Update()
    {
        planeMoveValue = shreders[0].finishedValue() + shreders[1].finishedValue() + shreders[2].finishedValue() + shreders[3].finishedValue();
        movePlane(planeMoveValue);
    }

    void movePlane(float x)
    {
        bloodPlane.transform.localPosition = Vector3.Slerp(bloodPlane.transform.localPosition, new Vector3(0, x, 0), riseSpeed * Time.deltaTime);
    }

    public float getPlaneValue()
    {
        return planeMoveValue;
    }
    public bool isPipesActive()
    {
        return (pipes[0].isRecieved() && pipes[1].isRecieved() && pipes[2].isRecieved());       
    }

}

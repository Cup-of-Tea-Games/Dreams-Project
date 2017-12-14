using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pilars : MonoBehaviour {

    public Animator anim;
    public KeyReciever pilar1;
    public KeyReciever pilar2;
    public KeyReciever pilar3;
    public Material emptyMat;
    public Material RecievedMat;
    bool active = false;

    void Update()
    {
        if (pilar1.isRecieved())
            pilar1.gameObject.GetComponent<Renderer>().materials[1] = RecievedMat;
        else
            pilar1.gameObject.GetComponent<Renderer>().materials[1] = emptyMat;

        if (pilar2.isRecieved())
            pilar2.gameObject.GetComponent<Renderer>().materials[1] = RecievedMat;
        else
            pilar2.gameObject.GetComponent<Renderer>().materials[1] = emptyMat;

        if (pilar3.isRecieved())
            pilar3.gameObject.GetComponent<Renderer>().materials[1] = RecievedMat;
        else
            pilar3.gameObject.GetComponent<Renderer>().materials[1] = emptyMat;

    }



    public bool isActive()
    {
        if (pilar1.isRecieved() && pilar2.isRecieved() && pilar3.isRecieved())
            active = true;

        return active;
    }

    public void setActive(bool x)
    {
        active = x;
    }

    public void rise()
    {
        anim.Play("Pilars Rise");
    }
}

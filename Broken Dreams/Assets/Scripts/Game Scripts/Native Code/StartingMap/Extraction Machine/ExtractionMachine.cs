using UnityEngine;
using System.Collections;

public class ExtractionMachine : MonoBehaviour {

    public Lever lever;
    public KeyReciever gear;
    public Engine engine;
    public Basement basement;
    TipsGenerator tips;
    bool key1 = true;
    bool key2 = true;
    public Pilars bioPilars;
    public ExtractionDoor doorA;
    public ExtractionDoor doorB;
    public Button electricityButon;
    public GameObject electricity;

    public AudioSource audioObject;

    void Awake()
    {
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();
    }

    void Update()
    {
        if(key1 && lever.isActivated() && gear.isRecieved())
        {
            key1 = false;
            doorA.open();
            doorB.open();
        }

        if (electricityButon.active && bioPilars.isActive())
        {
            electricity.SetActive(true);
        }

        if (key2 && electricity.activeSelf)
        {
            key2 = false;
            audioObject.gameObject.SetActive(true);
        } 
        else if (!electricity.activeSelf)
        {
            audioObject.gameObject.SetActive(false);
        }
    }

    public bool isOnline()
    {
        return electricity.activeSelf && lever.isActivated() && gear.isRecieved();
    }
}

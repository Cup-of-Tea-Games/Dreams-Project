using UnityEngine;
using System.Collections;

public class ExtractionMachine : MonoBehaviour {

    public Lever lever;
    public KeyReciever gear;
    public Engine engine;
    public Basement basement;
    TipsGenerator tips;
    bool key1 = true;

    void Awake()
    {
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();
    }

    void Update()
    {
        if(key1 && isOnline())
        {
            key1 = false;
            tips.Show("Comenza Festivale di Morte");
        }
    }

    public bool isOnline()
    {
        return lever.isActivated() && gear.isRecieved() && engine.isOnline() && basement.isOnline();
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ERPC : MonoBehaviour {

    public ButtonSimple power_BTN;
    public ButtonSimple bloodStat_BTN;
    public ButtonSimple bodyDiag_BTN;

    public GameObject power_SCRN;
    public GameObject bloodStat_SCRN;
    public GameObject bodyDiag_SCRN;
    public GameObject reroute_SCRN;
    public GameObject rerouting_SCRN;
    public GameObject rerouted_SCRN;

    public ButtonSimple reroute_BTN;

    public FloodedChamber chamber;

    public Text bloodFlowStat;
    public Text bloodPressureStat;

    bool active = false;

    int state = 1;

    void Update()
    {
        switch (state)
        {
            case 1:
                power_SCRN.SetActive(true);
                bloodStat_SCRN.SetActive(false);
                bodyDiag_SCRN.SetActive(false);
                reroute_SCRN.SetActive(false);
                reroute_BTN.gameObject.SetActive(false);
            break;

            case 2:
                power_SCRN.SetActive(false);
                bloodStat_SCRN.SetActive(true);
                bodyDiag_SCRN.SetActive(false);
                reroute_SCRN.SetActive(false);
                reroute_BTN.gameObject.SetActive(false);
                break;

            case 3:
                power_SCRN.SetActive(false);
                bloodStat_SCRN.SetActive(false);
                bodyDiag_SCRN.SetActive(true);
                reroute_SCRN.SetActive(false);
                reroute_BTN.gameObject.SetActive(false);
                break;

            case 4:
                power_SCRN.SetActive(false);
                bloodStat_SCRN.SetActive(false);
                bodyDiag_SCRN.SetActive(false);
                reroute_SCRN.SetActive(true);
                reroute_BTN.gameObject.SetActive(true);
                power_BTN.gameObject.SetActive(false);
                bloodStat_BTN.gameObject.SetActive(false);
                bodyDiag_BTN.gameObject.SetActive(false);
                break;
        }

        if (power_BTN.active)
            state = 1;
        else if (bloodStat_BTN.active)
            state = 2;
        else if (bodyDiag_BTN.active)
            state = 3;
        else if (chamber.isActive())
            state = 4;

        if (reroute_BTN.active)
        {
            if (!active)
                GetComponent<AudioSource>().Play();

            active = true;
        }

        bloodFlowStat.text = "" + chamber.getPlaneValue()*100 + "%";

        if (!chamber.isPipesActive())
            bloodPressureStat.text = "UNSTABLE";
        else
            bloodPressureStat.text = "NOMINAL";

    }

    public bool reroutedPower()
    {
        return active;
    }




}

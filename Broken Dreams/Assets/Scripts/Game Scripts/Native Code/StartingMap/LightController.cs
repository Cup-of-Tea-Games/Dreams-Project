using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightController : MonoBehaviour {


    public bool isInGenerator = false;
    public Light[] lightsOnGenerator;
    public Light[] lightsNotOnGenerator;
    public Material lightMat;

    void Update()
    {
        if (isInGenerator)
        {
            lightMat.SetColor("_EmissionColor", new Color(255, 0, 0, 255));

            for (int i = 0; i < lightsOnGenerator.Length; i++)
                if(lightsOnGenerator[i] != null)
                lightsOnGenerator[i].color = Color.red;

      //      for (int i = 0; i < lightsNotOnGenerator.Length; i++)
        //        if (lightsOnGenerator[i + 1] != null && lightsOnGenerator[i] != null)
          //          lightsNotOnGenerator[i].enabled = false;

        }
        else
        {
            lightMat.SetColor("_EmissionColor", new Color(255, 255, 255, 255));

            for (int i = 0; i < lightsOnGenerator.Length; i++)
                lightsOnGenerator[i].color = Color.white;

            for (int i = 0; i < lightsNotOnGenerator.Length; i++)
                lightsNotOnGenerator[i].enabled = true;

        }
    }

}

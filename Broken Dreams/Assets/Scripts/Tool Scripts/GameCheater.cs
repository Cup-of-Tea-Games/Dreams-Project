using UnityEngine;
using System.Collections;

public class GameCheater : MonoBehaviour {

    public string generatorOnline;
    public static string generatorOnlinetatic;
    public string instaDeath;
    public string regenHealth;

    void Awake()
    {
        generatorOnlinetatic = generatorOnline;
    }

    public static bool isGeneratorOnline()
    {
        if (Input.GetKey(generatorOnlinetatic))
            return true;
        else
            return false;
    }

    void Update()
    {
        if (Input.GetKey(instaDeath))
            PlayerHealth.health = 0;

        if (Input.GetKey(regenHealth))
            PlayerHealth.health = 100;
    }
	
}

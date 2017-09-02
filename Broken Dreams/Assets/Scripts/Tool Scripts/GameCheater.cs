using UnityEngine;
using System.Collections;

public class GameCheater : MonoBehaviour {

    public string generatorOnline;
    public static string generatorOnlinetatic;

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
	
}

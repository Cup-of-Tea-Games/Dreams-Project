using UnityEngine;
using System.Collections;

public class GameCheater : MonoBehaviour {

    public string generatorOnline;
    public static string generatorOnlinetatic;
    public string instaDeath;
    public string regenHealth;
    DamageMe damageSystem;

    void Awake()
    {
        generatorOnlinetatic = generatorOnline;
        damageSystem = GameObject.Find("Health&Damage").GetComponent<DamageMe>();
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
            damageSystem.takeDamage(100);

        if (Input.GetKey(regenHealth))
            PlayerHealth.health = 100;
    }
	
}

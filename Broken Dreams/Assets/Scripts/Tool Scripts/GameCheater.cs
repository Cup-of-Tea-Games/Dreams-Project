using UnityEngine;
using System.Collections;

public class GameCheater : MonoBehaviour {

    public string generatorOnline;
    public static string generatorOnlinetatic;
    public string instaDeath;
    public string regenHealth;
    public string instaInsanity;
    public string regenSanity;
    public string instagun;
    DamageMe damageSystem;
    Pilars biopilars;

    void Awake()
    {
        generatorOnlinetatic = generatorOnline;
        damageSystem = GameObject.Find("Health&Damage").GetComponent<DamageMe>();
        biopilars = GameObject.Find("Bio Pilars").GetComponent<Pilars>();
    }

    public static bool isGeneratorOnline()
    {
        if (Input.GetKey(generatorOnlinetatic))
        {
            return true;
        }
        else
            return false;
    }

    void Update()
    {
        if (Input.GetKey(instaDeath))
            damageSystem.takeDamage(100);

        if (Input.GetKey(regenHealth))
            PlayerHealth.health = 1000;

        if (Input.GetKey(instaInsanity))
            PlayerSanity.sanity = 0;

        if (Input.GetKey(regenSanity))
            PlayerSanity.sanity = 100;

        if (Input.GetKey(instagun))
            WeaponWheel.selectItemExternal(3);

        if (Input.GetKey(generatorOnlinetatic))
        {
            biopilars.setActive(true);
        }

    }
	
}

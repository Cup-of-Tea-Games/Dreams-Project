using UnityEngine;
using System.Collections;

public class Furnace : MonoBehaviour {

    public Collider hitBox;
    public int maxFuelLoad;
    public Engine engine;
    public TipsGenerator tips;
    public string nameOfFuel;
    public Animator animator;
    int currentFuelLoad = 0;
    public Lever lever;
    public GameObject fireObject1;
    public GameObject fireObject2;
    bool burnerOn = false;
    public Pilars pilars;

    //SFX
    public AudioSource furnaceBurnSFX;
    public AudioSource pilarsRiseSFX;

    //Temporary bool key
    bool key1 = true;


    void Update()
    {
        burnerOn = lever.isActivated();

        if (burnerOn)
        {
            fireObject1.SetActive(true);
            if (currentFuelLoad >= maxFuelLoad)
            {
                fireObject2.SetActive(true);
                if (key1)
                {
                    key1 = false;
                    engine.engineActive = true;
                    animator.Play("Close");
                    tips.Show("Engine Fueled");
                    pilarsRiseSFX.Play();
                    pilars.rise();
                }
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if(other.name == nameOfFuel)
        {
            Destroy(other,0f);
            currentFuelLoad++;
            furnaceBurnSFX.Play();
        }
    }

}

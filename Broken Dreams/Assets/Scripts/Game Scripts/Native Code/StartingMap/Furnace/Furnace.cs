using UnityEngine;
using System.Collections;

public class Furnace : MonoBehaviour {

    public Collider hitBox;
    public int maxFuelLoad;
    public Engine engine;
    TipsGenerator tips;
    public string nameOfFuel;
    public Animator animator;
    int currentFuelLoad = 0;
    public Lever lever;
    public GameObject fireObject;
    bool burnerOn = false;
    public Pilars pilars;

    //Temporary bool key
    bool key1 = true;

    void Awake()
    {
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();
    }

    void Update()
    {
        burnerOn = lever.isActivated();

        if (burnerOn)
        {
            fireObject.SetActive(true);
            if (currentFuelLoad >= maxFuelLoad && key1)
            {
                key1 = false;
                engine.engineActive = true;
                animator.Play("Close");
                tips.Show("Burner fuel full");
                pilars.rise();
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if(other.name == nameOfFuel)
        {
            Destroy(other,0f);
            currentFuelLoad++;
        }
    }

}

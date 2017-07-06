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

    //Temporary bool key
    bool key1 = true;

    void Update()
    {
        if(currentFuelLoad >= maxFuelLoad && key1)
        {
            key1 = false;
            engine.engineActive = true;
            animator.Play("Close");
            tips.Show("Burner fuel full");
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

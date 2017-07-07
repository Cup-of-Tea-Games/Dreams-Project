using UnityEngine;
using System.Collections;

public class DamagePoint : MonoBehaviour {

    public float damageValue = 10f;
    float damageRecieved = 0;
    bool hit = false;

    public void takeDamage(float amount)
    {
        hit = true;
        damageRecieved = damageValue + amount;
    }

    public float damageTaken()
    {
        return damageRecieved;
    }

    public bool isHit()
    {
        return hit;
    }

    public void resetValues()
    {
        hit = false;
        damageRecieved = 0;
    }

}

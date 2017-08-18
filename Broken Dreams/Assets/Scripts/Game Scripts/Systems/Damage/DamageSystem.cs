using UnityEngine;
using System.Collections;

public class DamageSystem : MonoBehaviour
{

    public DamagePoint[] damagePoints;
    public bool autoAssignDamagePoints = true;

    void Awake()
    {
        if (autoAssignDamagePoints)
        {
            DamagePoint[] temp = new DamagePoint[gameObject.GetComponentsInChildren<DamagePoint>().Length - 1];
            damagePoints.CopyTo(temp, 0);
            damagePoints = temp;
            for (int i = 0; i < gameObject.GetComponentsInChildren<DamagePoint>().Length; i++)
            {
                damagePoints[i] = gameObject.GetComponentsInChildren<DamagePoint>()[i];
            }
        }
    }

    public int getLength()
    {
        return damagePoints.Length;
    }

    public float damageTaken()
    {
        float tempInt = 0;

        for(int i = 0; i < damagePoints.Length; i++)
        {
            tempInt += damagePoints[i].damageTaken();
            damagePoints[i].resetValues();
        }
        return tempInt;
    }

    public bool isHit()
    {
        bool temp = false;

        for (int i = 0; i < damagePoints.Length; i++)
        {
            if (damagePoints[i].isHit())
            {
                temp = true;
                break;
            }
        }
        return temp;
    }
}

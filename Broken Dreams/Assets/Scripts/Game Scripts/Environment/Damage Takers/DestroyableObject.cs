using UnityEngine;
using System.Collections;

public class DestroyableObject : MonoBehaviour {

    public float health = 50f;

    public void takeDamage(float amount)
    {
        health -= amount;

        if (health <= 0f)
        {
            Destroy();
        }
    }

    void Destroy()
    {
        Destroy(gameObject);
    }
}

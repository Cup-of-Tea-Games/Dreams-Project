using UnityEngine;
using System.Collections;

public class DestroyableObject : MonoBehaviour {

    public float health = 50f;
    public GameObject destoryedVersion;

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
        GameObject brokenObject = Instantiate(destoryedVersion,transform) as GameObject;
        brokenObject.transform.position = this.transform.position;
        transform.DetachChildren();
        Destroy(gameObject,0f);
    }
}

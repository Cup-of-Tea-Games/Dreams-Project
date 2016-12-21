using UnityEngine;
using System.Collections;

public class FireRound : MonoBehaviour {

    public Transform barrelEnd;
    public GameObject projectile;
    public float speed;
    public static bool activate; //Activates behaviours from other places

    void Fire() {
        GameObject clone = Instantiate(projectile);
        clone.transform.position = barrelEnd.position;
        clone.GetComponent<Rigidbody>().AddForce(barrelEnd.forward * speed);

        activate = false;
    }

    void Update() {
        if (activate)
        {
            StartCoroutine(Delay());
        }
    }

    public IEnumerator Delay() {
        Fire();
        yield return new WaitForSeconds(1f);
        StopCoroutine(Delay());
    }
}

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class DamageMe : MonoBehaviour {
  
    bool canBeDamaged = true;
    Animator damageAnim;
    public AudioSource normalDamageSound;

    void Awake()
    {
        damageAnim = GetComponent<Animator>();
    }

    public void takeDamage(float x)
    {
        if (PlayerHealth.health > 0)
            if (canBeDamaged)
        {
            canBeDamaged = false;
            damageAnim.Play("NormalDamage");
            PlayerHealth.health -= x;
            normalDamageSound.Play();
            StartCoroutine(DamageDelay());
            PlayerHealth.InDanger = true;
        }
    }

    public IEnumerator DamageDelay()
    {
        yield return new WaitForSeconds(6f);
        canBeDamaged = true;
        StopCoroutine(DamageDelay());
        PlayerHealth.InDanger = false;
    }
}

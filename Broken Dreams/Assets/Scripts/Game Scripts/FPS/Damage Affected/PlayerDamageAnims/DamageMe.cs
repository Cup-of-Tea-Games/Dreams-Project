using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class DamageMe : MonoBehaviour {
  
    bool canBeDamaged = true;
    Animator damageAnim;
    public AudioSource normalDamageSound;
    public AudioSource progressiveDamageSound;

    void Awake()
    {
        damageAnim = GetComponent<Animator>();
    }

    public void takeDamage(int x)
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

    public void enterProgressiveDamageArea(float x)
    {
        if (PlayerHealth.health > 0)
        {
            damageAnim.Play("ProgressiveDamage");
            PlayerHealth.health -= x * Time.deltaTime;
            progressiveDamageSound.Play();
            PlayerHealth.InDanger = true;
        }
    }

    public void exitProgressiveDamageArea()
    {
        if (PlayerHealth.health > 0)
        {
            damageAnim.Play("ProgressiveDamage_Recover");
            PlayerHealth.InDanger = false;
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

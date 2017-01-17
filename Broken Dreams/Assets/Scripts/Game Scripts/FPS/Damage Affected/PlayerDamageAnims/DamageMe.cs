using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class DamageMe : MonoBehaviour {
  
    bool canBeDamaged = true;
    Animator damageAnim;
    public AudioSource normalDamageSound;
    public AudioSource progressiveDamageSound;
    public bool godMode;
    bool isInProgressiveDanagerArea = false;

    void Awake()
    {
        damageAnim = GetComponent<Animator>();
    }

    void Update()
    {
        if(isInProgressiveDanagerArea)
            PlayerHealth.health -= Time.deltaTime;
    }

    public void takeDamage(int x)
    {
        if (PlayerHealth.health > 0 && !godMode)
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

    public void enterProgressiveDamageArea()
    {
        if (PlayerHealth.health > 0 && !godMode)
        {
            damageAnim.Play("ProgressiveDamage");
            isInProgressiveDanagerArea = true;
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
            isInProgressiveDanagerArea = false;
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

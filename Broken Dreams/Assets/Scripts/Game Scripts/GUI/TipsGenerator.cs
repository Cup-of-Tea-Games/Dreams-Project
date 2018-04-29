using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class TipsGenerator : MonoBehaviour
{

    public Text message;
    Animator anim;
    bool isDisplayed = false;
    Color cl;
    string currentText;
    public float TipCooldownTime;
    public bool hasSFX;
    public AudioSource tipsSFX;

    void Awake()
    {
        anim = GetComponent<Animator>();
    }

    public void Show(string t)
    {
        message.text = t;
        if (!isDisplayed)
        {
            isDisplayed = true;
            //Fades In
            anim.StopPlayback();
            anim.Play("Tips");
            if (hasSFX)
                tipsSFX.Play();
            StartCoroutine(disable(TipCooldownTime));
        }

    }

    public IEnumerator disable(float x)
    {
        yield return new WaitForSeconds(x);
        isDisplayed = false;
        StopCoroutine(disable(x));
    }
}

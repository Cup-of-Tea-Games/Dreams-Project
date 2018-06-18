using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Fader : MonoBehaviour {

    public Image fadeImage;
    public float fadeSpeed = 0.8f;
    public int fadeDir = 0;
    private float alpha = 1.0f;

    void OnGUI()
    {
        alpha -= fadeDir * fadeSpeed * Time.deltaTime;
        alpha = Mathf.Clamp01(alpha);

        fadeImage.color = new Color(fadeImage.color.r, fadeImage.color.g,fadeImage.color.b,alpha);

        if(fadeImage.color.a == 0)
        {
            GetComponent<Image>().enabled = false;
        }
    }

    public float BeginFade(int direction)
    {
        fadeDir = direction;
        return (fadeSpeed);
    }

}

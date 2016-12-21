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
        alpha += fadeDir * fadeSpeed * Time.deltaTime;
        alpha = Mathf.Clamp01(alpha);

        fadeImage.color = new Color(GUI.color.r, GUI.color.g,GUI.color.b,alpha);
    }

    public float BeginFade(int direction)
    {
        fadeDir = direction;
        return (fadeSpeed);
    }

}

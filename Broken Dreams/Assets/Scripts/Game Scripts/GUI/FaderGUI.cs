using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class FaderGUI : MonoBehaviour {

    public static bool FadeIn = false;
    public static bool FadeOut = false;
    public float FadeRate;
    public bool fadeOutOnAwake = false;
    public Image fadeImage;
    private float targetAlpha;
    public bool fadeAudio = false;

    void Awake()
    {
        if (fadeOutOnAwake)
            fadeOut();
    }

    void Update()
    {
        if (FadeIn)
        {
            FadeIn = false;
            fadeIn();
        }
        else if (FadeOut)
        {
            FadeOut = false;
            fadeOut();
        }

        Color curColor = fadeImage.color;
        float alphaDiff = Mathf.Abs(curColor.a - targetAlpha);
        if (alphaDiff > 0.0001f)
        {
            curColor.a = Mathf.Lerp(curColor.a, targetAlpha, this.FadeRate * Time.deltaTime);
            this.fadeImage.color = curColor;
        }

        if (fadeAudio)
        {
            AudioListener.volume = -curColor.a;
        }
    }

    public void fadeIn()
    {
        targetAlpha = 1.5f;
    }

    public void fadeOut()
    {
        targetAlpha = -1.5f;
    }
}

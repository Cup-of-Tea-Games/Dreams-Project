using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.PostProcessing;

public class QualityLevel : MonoBehaviour {

    public Image lowButton;
    public Image mediumButton;
    public Image highButton;

    public Image onPostButton;
    public Image offPostButton;

    public Image onFullButton;
    public Image offFullButton;

    private int status;

    private int postStatus;

    public PostProcessingBehaviour postPros;

    void Awake()
    {

            selectPostLevel(1);
            selectQualityLevel(3);
            selectFullscreenLevel(1);
    }

    void Update()
    {

        if (PlayerPrefs.GetInt("status") == 1)
        {
            if(lowButton != null)
            lowButton.color = Color.red;
        }
        else
        {
            if (lowButton != null)
                lowButton.color = Color.white;
        }

        if (PlayerPrefs.GetInt("status") == 2)
        {
            if (mediumButton != null)
                mediumButton.color = Color.red;
        }
        else
        {
            if (mediumButton != null)
                mediumButton.color = Color.white;
        }

        if (PlayerPrefs.GetInt("status") == 3)
        {
            if (highButton != null)
                highButton.color = Color.red;
        }
        else
        {
            if (highButton != null)
                highButton.color = Color.white;
        }

        //Post Processing

        if (PlayerPrefs.GetInt("poststatus") == 0)
        {
            if (offPostButton != null)
                offPostButton.color = Color.red;


            if(postPros != null)
                postPros.enabled = false;
        }
        else
        {
            if (offPostButton != null)
                offPostButton.color = Color.white;
        }

        if (PlayerPrefs.GetInt("poststatus") == 1)
        {
            if (onPostButton != null)
                onPostButton.color = Color.red;

            if (postPros != null)
                postPros.enabled = true;
        }
        else
        {
            if (onPostButton != null)
                onPostButton.color = Color.white;
        }

        //Full Screen

        if (PlayerPrefs.GetInt("fullscreen") == 0)
        {
            if (offFullButton != null)
                offFullButton.color = Color.red;

            Screen.fullScreen = false;
        }
        else
        {
            if (offFullButton != null)
                offFullButton.color = Color.white;
        }

        if (PlayerPrefs.GetInt("fullscreen") == 1)
        {
            if (onFullButton != null)
                onFullButton.color = Color.red;

            Screen.fullScreen = true;
        }
        else
        {
            if (onFullButton != null)
                onFullButton.color = Color.white;
        }

    }

    public void selectQualityLevel(int x)
    {
        PlayerPrefs.SetInt("status", x);

        switch (x)
        {

            case 1:
                QualitySettings.SetQualityLevel(0);
            break;

            case 2:
                QualitySettings.SetQualityLevel(3);
            break;

            case 3:
                QualitySettings.SetQualityLevel(6);
            break;

        }

    }

    public void selectPostLevel(int x)
    {
        PlayerPrefs.SetInt("poststatus", x);

    }

    public void selectFullscreenLevel(int x)
    {
        PlayerPrefs.SetInt("fullscreen", x);

        if(x == 1)
        {
            Screen.fullScreenMode = FullScreenMode.FullScreenWindow;
            selectQualityLevel(PlayerPrefs.GetInt("status"));
        }
        else
        {
            Screen.fullScreenMode = FullScreenMode.Windowed;
            selectQualityLevel(PlayerPrefs.GetInt("status"));
        }

    }



}

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

    private int status;

    private int postStatus;

    public PostProcessingBehaviour postPros;

    void Awake()
    {
        selectPostLevel(1);
        selectQualityLevel(3);
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

            postPros.enabled = true;
        }
        else
        {
            if (onPostButton != null)
                onPostButton.color = Color.white;
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



}

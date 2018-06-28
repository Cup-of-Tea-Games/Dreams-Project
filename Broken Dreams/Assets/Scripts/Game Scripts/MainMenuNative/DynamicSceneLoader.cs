using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DynamicSceneLoader : MonoBehaviour {

    public Animator anim;
    public string animClipName;
    public float secondsDelay;
    public string scenename;

    public bool hasSceneLoader;

    public LO_LoadScene loader;
	
    public IEnumerator startTimer(float x)
    {
        yield return new WaitForSeconds(x);
        if (!hasSceneLoader)
            SceneManager.LoadScene(scenename);
        else
            loader.ChangeToScene(scenename);
        StopCoroutine(startTimer(x));
    }

    public void switchScene()
    {
        Time.timeScale = 1;
        if(anim != null)
        anim.Play(animClipName);
        StartCoroutine(startTimer(secondsDelay));
    }

    public void restart()
    {
        SceneManager.UnloadScene(Application.loadedLevelName);
        SceneManager.LoadScene(Application.loadedLevelName);
    }

    public void resetTimeScale()
    {
        Time.timeScale = 1;
    }
}

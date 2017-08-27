using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class SplashScene : MonoBehaviour {

    public float countDownTime;
    public string destination;

    void Start()
    {
        StartCoroutine(changeScene(countDownTime));
    }

    IEnumerator changeScene(float x)
    {
        yield return new WaitForSeconds(x);
        SceneManager.LoadScene(destination);
    }

}

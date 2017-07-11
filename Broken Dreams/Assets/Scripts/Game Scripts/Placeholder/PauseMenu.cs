using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour {

    public static bool isShowing = false;
    public GameObject Menu;

    void Update()
    {
        isShowing = Menu.activeSelf;

        if (Input.GetKey(KeyCode.Escape))
        {
            Menu.SetActive(true);
        }
    }

    public void hideMenu()
    {
        Menu.SetActive(false);
    }

    public void restart()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    public void quit()
    {
        Application.Quit();
    }
}

using UnityEngine;
using System.Collections;

public class ExitGame : MonoBehaviour {

    void Update()
    {
        if (Input.GetKey(KeyCode.Delete))
        {
            Debug.Log("Quitting Application");
            Application.Quit();
        }
    }
}

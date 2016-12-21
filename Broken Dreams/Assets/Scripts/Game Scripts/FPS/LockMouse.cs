using UnityEngine;
using System.Collections;

public class LockMouse : MonoBehaviour {

    public static bool lockMouse = true;
	
	// Update is called once per frame
	void Update () {
        if (lockMouse)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        else
        { 
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }

        //Part of crouching mechanic
    }

}

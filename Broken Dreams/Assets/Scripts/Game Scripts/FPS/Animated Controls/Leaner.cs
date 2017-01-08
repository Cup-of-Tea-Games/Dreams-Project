using UnityEngine;
using System.Collections;

public class Leaner : MonoBehaviour {

    bool leanLeft = false;
    bool leanRight = false;
 
    void Update()
    {

        if (Input.GetKeyDown(KeyCode.Q))
        {
            doLeanLeft();
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            doLeanRight();
        }

        if (Input.GetKeyUp(KeyCode.Q))
        {
            doLeanBack();
        }

        if (Input.GetKeyUp(KeyCode.E))
        {
            doLeanBack();
        }

    }

    void doLeanLeft()
    {
        if (leanLeft == false)
        {
            if (transform.rotation.z <= 30)
            transform.rotation = Quaternion.Euler(0, 0, 30*Time.deltaTime);
            leanLeft = false;
        }

    }

    void doLeanRight()
    {

        if (leanRight == false)
        {
            transform.rotation = Quaternion.Euler(0, 0, -30);
            leanRight = false;
        }

    }

    void doLeanBack()
    {
        transform.rotation = Quaternion.Euler(0, 0, 0);
    }
}

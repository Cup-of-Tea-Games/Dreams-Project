using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Peeking : MonoBehaviour {

    bool isNeutral;
    public static bool isPeeking = false;
    float rot = 0;
    public static bool isInMiddle = true;

    void Update () {

        Debug.Log(isInMiddle);

        if (transform.localRotation.z <= -0.25f)
            if (isPeeking)
                rot = 0;
        if (transform.localRotation.z >= 0.25f)
            if (isPeeking)
                rot = 0;

        if (transform.localRotation.z <= 0.005f && transform.localRotation.z >= -0.005f)
        {
            isInMiddle = true;
        }
        else
            isInMiddle = false;

        transform.Rotate(Vector3.forward, rot);

        if (Input.GetKey(KeyCode.Q))
        {
            //if (transform.localRotation.z <= 0.25f)
           //     transform.localPosition = Vector3.left * 1.5f;
            if (transform.localRotation.z <= 0.25f)
                rot = 1;
            isPeeking = true;
            isNeutral = false;
        }
        else if (Input.GetKey(KeyCode.E))
        {
           //   transform.localPosition = Vector3.left * -1.5f;
            if (transform.localRotation.z >= -0.25f)
                rot = -1;
            isPeeking = true;
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.E) || Input.GetKeyUp(KeyCode.Q))
        {
            isPeeking = false;
        }


        else
        {
            if (isInMiddle && !isPeeking)
            {
                rot = 0;
            }

            else if (transform.localRotation.z > 0.01f && !isInMiddle && !isPeeking)
            {
                rot = -1.1f;
            }
            else if (transform.localRotation.z < -0.01f && !isInMiddle && !isPeeking)
            {
                rot = 1.1f;
            }
        }

      //Resetter


    }


    public IEnumerator letGoPeek()
    {
        yield return new WaitForSeconds(0.1f);
        isPeeking = false;
        FirstPersonController.mouseLookResetter = true;
    }

}


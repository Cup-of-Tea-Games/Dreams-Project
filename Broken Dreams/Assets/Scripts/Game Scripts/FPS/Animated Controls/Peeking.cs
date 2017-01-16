using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Peeking : MonoBehaviour {

    bool isNeutral;
    public static bool isPeeking = false;
    public Transform transformLookAt;

    void Update () {

        transform.LookAt(transformLookAt);


        if (Input.GetKeyDown(KeyCode.Q))
        {
            transformLookAt.localPosition += Vector3.left * 1.5f;
            isPeeking = true;
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.Q))
        {
            transformLookAt.localPosition += Vector3.left * -1.5f;
            isPeeking = true;
            StartCoroutine(letGoPeek());
            isNeutral = false;
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            transformLookAt.localPosition += Vector3.left * -1.5f;
            isPeeking = true;
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.E))
        {
            transformLookAt.localPosition += Vector3.left * 1.5f;
            isPeeking = true;
            StartCoroutine(letGoPeek());
            isNeutral = false;
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


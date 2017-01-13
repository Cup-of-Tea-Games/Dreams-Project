using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Peeking : MonoBehaviour {

    bool isNeutral;
    public static bool isPeeking = false;

    void Update () {

	  if(Input.GetKeyDown(KeyCode.Q))
        {
            transform.localPosition += Vector3.left * 1.5f;
            transform.Rotate(Vector3.forward, 30f);
            isPeeking = true;
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.Q))
        {
            transform.localPosition += Vector3.left * -1.5f;
            transform.Rotate(Vector3.forward, -30f);
            isPeeking = true;
            StartCoroutine(letGoPeek());
            isNeutral = false;
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            transform.localPosition += Vector3.left * -1.5f;
            transform.Rotate(Vector3.forward, -30f);
            isPeeking = true;
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.E))
        {
            transform.localPosition += Vector3.left * 1.5f;
            transform.Rotate(Vector3.forward, 30f);
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


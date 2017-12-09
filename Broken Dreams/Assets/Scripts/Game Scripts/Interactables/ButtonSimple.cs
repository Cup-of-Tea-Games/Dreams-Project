using UnityEngine;
using System.Collections;

public class ButtonSimple : MonoBehaviour
{

    public bool isLocked = false;
    public bool active = false;
    public float buttonWaitTime = 2f;

    public void activate()
    {
        StartCoroutine(activate(buttonWaitTime));
    }

    public IEnumerator activate(float x)
    {
        if (!isLocked)
        {
            active = !active;
        }
        else if (isLocked)
        {
          //  tips.Show("It appears to be locked");
        }

        GetComponent<Collider>().enabled = false;
        yield return new WaitForSeconds(x);
        GetComponent<Collider>().enabled = true;
        StopCoroutine(activate(x));

    }
}

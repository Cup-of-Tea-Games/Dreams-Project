using UnityEngine;
using System.Collections;

public class ButtonSimple : MonoBehaviour
{

    public bool isLocked = false;
    public bool active = false;
    public float buttonWaitTime = 2f;
    public bool instantMode = false;

    public void activate()
    {
        StartCoroutine(activate(buttonWaitTime));
    }

    public IEnumerator activate(float x)
    {
        if (!isLocked)
        {
            if(!instantMode)
            active = !active;
            else
            {
                active = true;
                yield return new WaitForSeconds(0.1f);
                active = false;
            }
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

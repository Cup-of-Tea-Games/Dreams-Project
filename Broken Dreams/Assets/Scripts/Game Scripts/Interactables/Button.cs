using UnityEngine;
using System.Collections;

public class Button : MonoBehaviour {

    public GameObject buttonLight;
    public bool hasPower = true;
    public bool isLocked = false;
    public bool active = false;
    public Material activeMaterial;
    public Material deactiveMaterial;
    public Material noPowerMaterial;
    public Material lockedMaterial;
    public float buttonWaitTime = 2f;
    TipsGenerator tips;
    public bool hasSounds = false;
    public AudioClip toggleON;
    public AudioClip toggleOFF;
    public AudioClip toggleFail;

    public void activate()
    {
        StartCoroutine(activate(buttonWaitTime));
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();
    }

    void Update()
    {
        if (hasPower)
        {
            if (isLocked)
            {
                buttonLight.GetComponent<Renderer>().material = lockedMaterial;
            }
            else if (active)
            {
             buttonLight.GetComponent<Renderer>().material = activeMaterial;
            }
            else if (!active)
            {
                buttonLight.GetComponent<Renderer>().material = deactiveMaterial;
            }
        }
        else
        {
            buttonLight.GetComponent<Renderer>().material = noPowerMaterial;
        }
    }

    public IEnumerator activate(float x)
    {
        if (hasPower && !isLocked)
        {
            if(active == false)
                {
                    active = true;
                if (GetComponent<AudioSource>() != null)
                    GetComponent<AudioSource>().PlayOneShot(toggleON);
                }
                else
                {
                    active = false;
                if (GetComponent<AudioSource>() != null)
                    GetComponent<AudioSource>().PlayOneShot(toggleOFF);
                }
        }
        else if (hasPower && isLocked)
        {
            tips.Show("It appears to be locked");
            if (GetComponent<AudioSource>() != null)
                GetComponent<AudioSource>().PlayOneShot(toggleFail);
        }
        else if (!hasPower)
        {
            tips.Show("There is no power to open the door");
        }
        GetComponent<Collider>().enabled = false;
        yield return new WaitForSeconds(x);
        GetComponent<Collider>().enabled = true;
        StopCoroutine(activate(x));

    }
}

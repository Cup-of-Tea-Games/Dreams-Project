using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BodyShreder : MonoBehaviour {

    public ButtonSimple button;
    bool active = false;
    public GameObject bloodEnter;
    public GameObject bloodExit;
    bool hasShreded = false;
    Animator anim;
    Collider col;

    void Awake()
    {
        anim = GetComponent<Animator>();
    }

    void Update()
    {
        if (!active && button.active)
            activateButton();
    }

    void activateButton()
    {
        active = true;
        anim.Play("Activate");
    }

    public IEnumerator shred()
    {
        anim.Play("Shred");
        bloodEnter.SetActive(true);
        yield return new WaitForSeconds(4f);
        Destroy(bloodEnter);
        bloodExit.SetActive(true);
        hasShreded = true;
        col.enabled = false;
    }

    public bool finishedShreding()
    {
        return hasShreded;
    }

    public float finishedValue()
    {
        if (finishedShreding())
            return 0.25f;
        else
            return 0;
    }

    void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.name.Contains("Limb") && active)
        {
            Destroy(col.gameObject);
            StartCoroutine(shred());
        }
    }
}

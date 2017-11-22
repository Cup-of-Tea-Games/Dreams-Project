using UnityEngine;
using System.Collections;

public class Valve : MonoBehaviour {

    public string tag = "Water";
    public Animator animator;
    public Collider col;
    public Toggle toggle;
    TipsGenerator tips;

    bool key1 = true;
    bool active = false;

    void Awake()
    {
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();
    }

    void Update()
    {

        //Debug.Log(toggle.currentState());

        if (toggle.currentState() && key1)
        {
            key1 = false;
            Destroy(col);
            animator.Play("Spin");
            tips.Show(tag + " Pressure stabalized");
            active = true;
        }
    }

    public bool isActive()
    {
        return active;
    }

}

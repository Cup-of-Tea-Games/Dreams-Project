using UnityEngine;
using System.Collections;

public class AnimatorTrigger : MonoBehaviour {
    
    public Animator animator;
    public string tagName;
    public bool status;
    bool activated;

    void OnTriggerEnter(Collider col)
    {
        if (col.tag == tagName && activated)
        {
            animator.enabled = status;
        }
    }

    void Start()
    {
        Debug.Log("as");
        activated = true;
    }
}

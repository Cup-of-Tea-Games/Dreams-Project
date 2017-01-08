using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Peeking : MonoBehaviour {

    public Animator animator;
    bool isNeutral;
	
	void Update () {

	  if(Input.GetKeyDown(KeyCode.Q) && isClear())
        {
            animator.Play("Lean Left");
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.Q) && isClear())
        {
            animator.Play("Lean Back Left");
            isNeutral = false;
        }
        else if (Input.GetKeyDown(KeyCode.E) && isClear())
        {
            animator.Play("Lean Right");
            isNeutral = false;
        }
        else if (Input.GetKeyUp(KeyCode.E) && isClear())
        {
            animator.Play("Lean Back Right");
            isNeutral = false;
        }
        else if (animator.GetCurrentAnimatorStateInfo(0).IsName("Neutral"))
        {
            isNeutral = true;
        }

      //Resetter
        if (isNeutral)
        {
            animator.enabled = false;
            FirstPersonController.isPeeking = false;
        }
        else
        {
            animator.enabled = true;
            FirstPersonController.isPeeking = true;
        }

    }

    bool isPlaying(string s)
    {
        return (animator.GetCurrentAnimatorStateInfo(0).IsName(s));
    }

    bool isClear()
    {
        return !(isPlaying("Lean Left") && isPlaying("Lean Back Left") && isPlaying("Lean Right") && isPlaying("Lean Back Right"));
    }

}


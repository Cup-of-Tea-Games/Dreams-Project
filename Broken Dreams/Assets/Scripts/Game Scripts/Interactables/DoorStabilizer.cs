using UnityEngine;
using System.Collections;

public class DoorStabilizer : MonoBehaviour {

    HingeJoint hinger;
    bool clear = true;
    bool megaDelay = true;
    public AudioClip doorClose;

    void Awake ()
    {
        hinger = GetComponent<HingeJoint>();
        GetComponent<AudioSource>().clip = doorClose;
    }
		void Update () {

        if (hinger.angle >= 80 || hinger.angle <= -80 && megaDelay)
        {
            StartCoroutine(delayTime());
        }

        if (clear)
            hinger.useSpring = true;
        else
            hinger.useSpring = false;

        HandleSounds();

	}

    public IEnumerator delayTime()
    {
        megaDelay = false;
        clear = false;
        yield return new WaitForSeconds(2);
        clear = true;
    }

    void HandleSounds()
    {

        if (hinger.angle <= 1 && (GetComponent<Rigidbody>().velocity.x >= 0.2f || GetComponent<Rigidbody>().velocity.x <= -0.2f))
        {
            GetComponent<AudioSource>().Play();
        }
        
           
    }

}

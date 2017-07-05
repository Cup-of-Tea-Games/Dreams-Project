using UnityEngine;
using System.Collections;

public class Door : MonoBehaviour
{

    public string keyTag;
    public bool isLocked;
    public bool ignoreOnOpen = false;
    Rigidbody doorPhysics;
    HingeJoint hinge;
    public float targetVelocity = 80;
    public float force = 70;
    public bool doesItHaveSound = false;
    public float pitchMultiplier = 1;
    public AudioClip clip;
    AudioSource audio;
    AudioSource audio2;
    public bool hasCloseSounds = false;
    public AudioClip closeClip;
    public bool hasKnob = false;
    public GameObject Knob;
    Animator knobAnim;

    //Tools
    bool doorIsOpen = false;
    bool doorActivation;
    bool closeActivaton = false;
    public bool initialState = false;

    void Update()
    {
        lockHandeler();

        if (ignoreOnOpen)
        {
            if ((audio.isPlaying || audio2.isPlaying) && audio != null && audio2 != null)
                GetComponent<Collider>().enabled = false;
            else
                GetComponent<Collider>().enabled = true;
        }

        if (hinge.angle == hinge.limits.min && closeActivaton)
        {
            if (doesItHaveSound && hasCloseSounds)
            {
                closeActivaton = false;
                audio2.clip = closeClip;
                audio2.pitch = 1f * pitchMultiplier;
                audio2.Play();
            }

            if (hasKnob)
            {
             //   knobAnim.Play("DoorKnob");
            }
        }
    }

    public void toggle()
    {
        if (doorIsOpen || !doorIsOpen)
            doorIsOpen = !doorIsOpen;
        doorActivation = true;
        stateHandeler();
    }

    void Awake()
    {
        doorPhysics = GetComponent<Rigidbody>();
        hinge = GetComponent<HingeJoint>();
        doorIsOpen = false;
        if (doesItHaveSound)
            audio = GetComponent<AudioSource>();

        if (hasCloseSounds)
        {
            audio2 = gameObject.AddComponent<AudioSource>();
            audio2.spatialBlend = audio.spatialBlend;
        }

        if (hasKnob)
        {
            knobAnim = Knob.GetComponent<Animator>();
        }

        if(initialState)
        toggle();
    }
    public void unlockDoor()
    {
        isLocked = false;
    }

    void lockHandeler()
    {
        if (isLocked)
            doorPhysics.isKinematic = true;
        else
            doorPhysics.isKinematic = false;

    }

    void stateHandeler()
    {
        if(!isLocked)
        if (doorIsOpen)
        {
            if (hinge.angle != 90 && doorActivation)
            {
                closeActivaton = true;
                JointMotor motor = hinge.motor;
                motor.force = force;
                motor.targetVelocity = targetVelocity;
                motor.freeSpin = false;
                hinge.motor = motor;
                hinge.useMotor = true;
                    if (doesItHaveSound)
                    {
                        audio.clip = clip;
                        audio.pitch = 1.1f*pitchMultiplier;
                        audio.Play();
                    }

                    if (doesItHaveSound && hasCloseSounds)
                    {
                        audio2.clip = closeClip;
                        audio2.pitch = 1f * pitchMultiplier;
                        audio2.Play();
                    }
                    if (hasKnob)
                    {
                        knobAnim.Play("DoorKnob");
                    }
                }
        }
        else if (hinge.angle != 0 && doorActivation)
        {
            if (hinge.angle != 0 && doorActivation)
            {
                    closeActivaton = true;
                    JointMotor motor = hinge.motor;
                motor.force = force;
                motor.targetVelocity = -targetVelocity;
                motor.freeSpin = false;
                hinge.motor = motor;
                hinge.useMotor = true;
                    if (doesItHaveSound)
                    {
                        audio.clip = clip;
                        audio.pitch = 0.9f*pitchMultiplier;
                        audio.Play();
                    }
                }
        }
    }
}

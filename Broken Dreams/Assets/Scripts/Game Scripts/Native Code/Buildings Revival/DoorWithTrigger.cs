using UnityEngine;
using System.Collections;

public class DoorWithTrigger : Door {

    public GameObject triggerItemSpawn;
    Rigidbody doorPhysics;
    HingeJoint hinge;

    //Tools
    bool doorIsOpen = false;
    bool doorActivation;

    void Update()
    {
        lockHandeler();

        stateHandeler();
    }

    void Awake()
    {
        doorPhysics = GetComponent<Rigidbody>();
        hinge = GetComponent<HingeJoint>();
    }

    void lockHandeler()
    {
        if (isLocked)
        {
            doorPhysics.isKinematic = true;
        }
        else
        {
            doorPhysics.isKinematic = false;
            triggerItemSpawn.SetActive(true);
        }

    }

    public void toggle()
    {
        if (doorIsOpen || !doorIsOpen)
            doorIsOpen = !doorIsOpen;
        doorActivation = true;
        Debug.Log(doorIsOpen);
    }

    public void unlockDoor()
    {
        isLocked = false;
    }

    void stateHandeler()
    {
        if (!isLocked)
            if (doorIsOpen)
            {
                if (hinge.angle != 90 && doorActivation)
                {
                    JointMotor motor = hinge.motor;
                    motor.force = 100;
                    motor.targetVelocity = 75;
                    motor.freeSpin = false;
                    hinge.motor = motor;
                    hinge.useMotor = true;
                }
                else if (hinge.useMotor && hinge.angle == 90)
                {
                    hinge.useMotor = false;
                    doorActivation = false;
                }
            }
            else if (hinge.angle != 0 && doorActivation)
            {
                if (hinge.angle != 0 && doorActivation)
                {
                    JointMotor motor = hinge.motor;
                    motor.force = 100;
                    motor.targetVelocity = -75;
                    motor.freeSpin = false;
                    hinge.motor = motor;
                    hinge.useMotor = true;
                }
                else if (hinge.useMotor && hinge.angle == 0)
                {
                    hinge.useMotor = false;
                    doorActivation = false;
                }
            }
    }
}

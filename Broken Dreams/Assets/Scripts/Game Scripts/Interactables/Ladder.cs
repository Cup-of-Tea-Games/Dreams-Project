using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class Ladder : MonoBehaviour {

    public Transform ClimbPosition;
    Vector3 ClimbPositionVector;
    public Transform topLimit;
    public Transform bottomLimit;

    GameObject player;

    void Awake()
    {
        player = GameObject.Find("Player");
        ClimbPositionVector = ClimbPosition.position;
    }

    void Update()
    {

        if (!FirstPersonController.isClimbing)
        {
            if (player.transform.position.y <= topLimit.position.y -4f)
                ClimbPositionVector.y = player.transform.position.y + 1.5f;
            ClimbPosition.position = ClimbPositionVector;
        }
        else
        {
            if (ClimbPosition.position.y >= topLimit.position.y)
            {
                    FirstPersonController.isClimbing = false;
                    ClimbPositionVector = topLimit.position;
                    ClimbPositionVector.y = topLimit.position.y - 3;
            }
            else if (ClimbPosition.position.y <= bottomLimit.position.y)
            {
                ClimbPositionVector.y = bottomLimit.position.y + 1;
                FirstPersonController.isClimbing = false;
            }
        }
    }
}

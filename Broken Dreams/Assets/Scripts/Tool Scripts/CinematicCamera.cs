using UnityEngine;
using System.Collections;

public class CinematicCamera : MonoBehaviour
{
    public float moveSpeed = 1.0f;
    public float turnSpeed = 1.0f;


    void Update()
    {
        float x = Input.GetAxis("Horizontal") * Time.deltaTime * turnSpeed * 3.0f;
        float z = Input.GetAxis("Vertical") * Time.deltaTime * moveSpeed * 3.0f;
        float up = Input.GetAxis("Up") * Time.deltaTime * moveSpeed * 3.0f;

        transform.Translate(x, 0, 0);
        transform.Translate(0, 0, z);
        transform.Translate(0, up, 0);
    }
}
    

using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class HeadBobber : MonoBehaviour
{

    private float timer = 0.0f;
    public  float bobbingSpeed = 0.18f;
    public  float bobbingAmount = 0.2f;
    public float midpoint = 2.0f;
    public float smoothing = 50;

    void Update()
    {

        Debug.Log(FirstPersonController.currentSpeed);
        float waveslice = 0.0f;
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 cSharpConversion = transform.localPosition;

        if (Mathf.Abs(horizontal) == 0 && Mathf.Abs(vertical) == 0)
        {
            timer = 0.0f;
        }
        else {
            waveslice = Mathf.Sin(timer);
            timer = timer + bobbingSpeed*FirstPersonController.currentSpeed;
            if (timer > Mathf.PI * 2)
            {
                timer = timer - (Mathf.PI * 2);
            }
        }
        if (waveslice != 0)
        {
            float translateChange = waveslice * bobbingAmount;
            float totalAxes = Mathf.Abs(horizontal) + Mathf.Abs(vertical);
            totalAxes = Mathf.Clamp(totalAxes, 0.0f, 1.0f);
            translateChange = totalAxes * translateChange;
            cSharpConversion.y = midpoint + translateChange*2;
            cSharpConversion.x = midpoint + translateChange;
        }
        else {
            cSharpConversion.y = midpoint;
            cSharpConversion.x = midpoint;
        }

        transform.localPosition = Vector3.Lerp(transform.localPosition, cSharpConversion, Time.deltaTime*smoothing);
    }



}
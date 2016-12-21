using UnityEngine;
using System.Collections;

public class PerlinNoise : MonoBehaviour {

    // Transform of the camera to shake. Grabs the gameObject's transform
    // if null.
    public Transform camTransform;

    // How long the object should shake for.
    public float shake = 0f;

    // Amplitude of the shake. A larger value shakes the camera harder.
    public float shakeAmount = 0.7f;
    public float decreaseFactor = 1.0f;

    Vector3 originalPos;

    bool isShaking;

    void Awake()
    {
        if (camTransform == null)
        {
            camTransform = GetComponent(typeof(Transform)) as Transform;
        }
    }

    void OnEnable()
    {
        originalPos = camTransform.localPosition;
    }

    public void shakeCamera(bool x)
    {
        if (x)
        {
            camTransform.localPosition = originalPos + Random.insideUnitSphere * shakeAmount;
        }
        else
        {
            shake = 0f;
            camTransform.localPosition = originalPos;
        }
    }

    void Update()
    {
        if (shake > 0)
        {
            camTransform.localPosition = originalPos + Random.insideUnitSphere * shakeAmount;
            isShaking = true;
            shake -= Time.deltaTime * decreaseFactor;
        }
        else
        {
            shake = 0f;
            if (isShaking && camTransform.localPosition != originalPos)
                camTransform.localPosition = originalPos;
            else if (!isShaking && camTransform.localPosition == originalPos)
                isShaking = false;
        }
    }
}

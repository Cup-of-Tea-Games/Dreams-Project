using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class ToolTipMover : MonoBehaviour
{

    RectTransform thisImage;
    public GameObject attributes;

    void Awake()
    {
        thisImage = GetComponent<RectTransform>();
    }

    void Update()
    {
        if (LockMouse.lockMouse == false)
        {
            thisImage.transform.position = Input.mousePosition;
            if (!attributes.activeSelf)
                attributes.SetActive(true);
        }
        else
        {
            if(attributes.activeSelf)
            attributes.SetActive(false);
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MouseChaser : MonoBehaviour {

	void Update()
    {
        gameObject.GetComponent<RectTransform>().localPosition = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
    }
}

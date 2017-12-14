using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextClamp : MonoBehaviour {

    public Image image;
    public Text itext;
    public Camera cam;
    PickItem pickItem;
    public Vector3 offset = new Vector3(0f, 1f, 0f);
    public MeshRenderer mesh;
    public float offsetFloat = 0;

    void Awake()
    {
        pickItem = GetComponent<PickItem>();
    }

	void Update () {
        float distance = Vector3.Distance(gameObject.transform.position, cam.transform.position);

        if(distance < 2 + offsetFloat && mesh.isVisible)
        {
            Vector3 imagePos = cam.WorldToScreenPoint(this.transform.position);
            //    image.transform.position = Vector2.Lerp(image.transform.position,imagePos,100*Time.deltaTime);
            image.transform.position = imagePos + offset;
            image.gameObject.SetActive(true);
            itext.text = pickItem.itemName;
        }
        else if (distance >= 2+offsetFloat && distance <= 3 + offsetFloat)
        {
            image.gameObject.SetActive(false);
        }
    }

    public void disable()
    {
        image.gameObject.SetActive(false);
    }
}

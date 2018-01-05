using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextClamp : MonoBehaviour {

    public Image image;
    public Text itext;
    public Camera cam;
    PickItem pickItem;
    PickPage pickPage;
    public Vector3 offset = new Vector3(0f, 1f, 0f);
    public MeshRenderer mesh;
    public float offsetFloat = 0;
    public bool autoFindName = false;
    string name;
    public Drawer drawer;

    void Awake()
    {
        if (autoFindName)
        {
            image = GameObject.Find("ItemNameDisplay A").GetComponent<Image>();
            itext = GameObject.Find("ItemTextDisplay A").GetComponent<Text>();
            cam = GameObject.Find("FirstPersonCharacter").GetComponent<Camera>();
        }
        if (GetComponent<PickItem>() != null)
        {
            pickItem = GetComponent<PickItem>();
            name = pickItem.itemName;
        }
        else if (GetComponent<PickPage>() != null)
        {
            pickPage = GetComponent<PickPage>();
            name = pickPage.title;
        }
    }

	void Update () {
        float distance = Vector3.Distance(gameObject.transform.position, cam.transform.position);

        if(drawer == null)
        if (!PageViewer.PageViewerIsUp && !InventoryMenu.inventroyIsUp) {
            if (distance < 2 + offsetFloat)
            {

                Vector3 imagePos = cam.WorldToScreenPoint(this.transform.position);
                //    image.transform.position = Vector2.Lerp(image.transform.position,imagePos,100*Time.deltaTime);
                image.transform.position = imagePos + offset;
                image.gameObject.SetActive(true);
                itext.text = name;
            }
            else if (distance >= 2 + offsetFloat && distance <= 3 + offsetFloat)
            {
                image.gameObject.SetActive(false);
            }
        }
        else
            disable();
        else
        {
            if (!PageViewer.PageViewerIsUp && !InventoryMenu.inventroyIsUp)
            {
                if (drawer.toggle && distance < 2 + offsetFloat)
                {
                    if (distance < 2 + offsetFloat)
                    {

                        Vector3 imagePos = cam.WorldToScreenPoint(this.transform.position);
                        //    image.transform.position = Vector2.Lerp(image.transform.position,imagePos,100*Time.deltaTime);
                        image.transform.position = imagePos + offset;
                        image.gameObject.SetActive(true);
                        itext.text = name;
                    }
                    else if (distance >= 2 + offsetFloat && distance <= 3 + offsetFloat && !drawer.toggle)
                    {
                        image.gameObject.SetActive(false);
                    }
                }
                else
                {
                    image.gameObject.SetActive(false);
                }
            }
            else
                disable();
        }
    }

    public void disable()
    {
        image.gameObject.SetActive(false);
    }
}

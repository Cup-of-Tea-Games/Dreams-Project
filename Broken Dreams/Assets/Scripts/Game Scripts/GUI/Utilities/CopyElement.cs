using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class CopyElement : MonoBehaviour {

    public Item copyItem;
    public Item pasteItem;
    public Image image;

    void Update()
    {
        image.sprite = copyItem.image;
        pasteItem.image = copyItem.image;
        pasteItem.itemName = copyItem.itemName;
        pasteItem.itemDesc = copyItem.itemDesc;
        pasteItem.itemTag = copyItem.itemTag;
    }
}

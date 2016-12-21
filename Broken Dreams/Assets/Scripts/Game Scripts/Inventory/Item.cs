using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Item : MonoBehaviour {
    public Sprite emptyImage;
    protected Sprite image;
    protected string itemName;
    protected string itemDesc;
    protected string itemTag;

    void Awake()
    {
        itemName = "";
        itemDesc = "";
        itemTag = "";
        image = emptyImage;
        GetComponent<Image>().sprite = image;
    }

    public Item()
    {
        itemName = "";
        itemDesc = "";
        itemTag = "";
        image = emptyImage;
    }

    public Item(Sprite aimage, string aitemTag, string aName , string desc)
    {
        image = aimage;
        itemTag = aitemTag;
        itemName = aName;
        itemDesc = desc;
    }

    public Item(Item aItem)
    {
        image = aItem.image;
        itemTag = aItem.itemTag;
        itemName = aItem.itemName;
        itemDesc = aItem.itemDesc;
    }

    public Sprite getImage()
    {
        return (image);
    }

    public void setImage(Sprite i)
    {
        image = i;
    }

    public void setImageComponent(Sprite i)
    {
        GetComponent<Image>().sprite = i;
    }

    public string getTag()
    {
        return itemTag;
    }

    public void setTag(string s)
    {
        itemTag = s;
    }

    public string getitemName()
    {
        return itemName;
    }

    public void setitemName(string s)
    {
        itemName = s;
    }

    public string getDesc()
    {
        return itemDesc;
    }

    public void setDesc(string s)
    {
        itemDesc = s;
    }

    public bool isEmpty()
    {
        return (itemName == "" && image == emptyImage && itemDesc == "" && itemTag == "");
    }

    public void delete()
    {
        setImage(emptyImage);
        itemName = "";
        itemDesc = "";
        itemTag = "";
        setImageComponent(emptyImage);
    }

    public void selectThisItem()
    {
        Selector.selectedItem = this;
    }

}

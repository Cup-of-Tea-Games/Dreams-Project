using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Main_Item : MonoBehaviour {
    private Sprite emptyImage;
    private string itemName;
    private string itemDesc;
    private string itemTag;

    public int typeItem;

    void Awake()
    {
        if (typeItem == 1)
            itemTag = "Light_MAIN";
        else if (typeItem == 2)
            itemTag = "Health_MAIN";
        else if (typeItem == 3)
            itemTag = "Sanity_MAIN";
    }

    void Main_item()
    {
        itemName = "";
        itemDesc = "";
        itemTag = "";
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
        return (false);
    }

    public void delete()
    {
        itemName = "";
        itemDesc = "";
        itemTag = "";
    }

    public void selectThisItem()
    {
        Selector.selectedMain = this;
    }
}

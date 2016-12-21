using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Hand : MonoBehaviour {

    public static Item itemInstance;

    void Awake()
    {
        itemInstance = new Item();
    }

    public void clearHand()
    {
        itemInstance.delete();
    }

    public bool isEmpty()
    {
        return (itemInstance.isEmpty());
    }

    public string getItemTag()
    {
        return itemInstance.getTag();
    }

    public Sprite getItemImage()
    {
        return itemInstance.getImage();
    }
}

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PickItem : MonoBehaviour {

   public  Sprite itemImage;
   public string itemTag;
   public  string itemName;
   public  string itemDesc;
   public ItemShack itemShack;
   GameObject tipsGen;
   TipsGenerator tips;
   public string messageOnPickUp;

    void Awake()
    {
        tipsGen = GameObject.Find("ItemTips");
        tips = tipsGen.GetComponent<TipsGenerator>();
    }

    void Start()
    {
    }

    public void pickUpItem()
    {
        itemShack.add(new Item(itemImage, itemTag, itemName, itemDesc));
        tips.Show(messageOnPickUp);
        Destroy(gameObject);
    }
}

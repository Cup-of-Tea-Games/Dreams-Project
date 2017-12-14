using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PickItem : MonoBehaviour {

   public  Sprite itemImage;
   public string itemTag;
   public  string itemName;
   public  string itemDesc;
   public ItemShack itemShack;
   TipsGenerator tips;
   public string messageOnPickUp;
   public bool autoFindItemShack = true;
   public bool autoFindWeaponShack = false;
   public bool destroyOnPickUp = true;

    void Awake()
    {
        tips = GameObject.Find("Tips").GetComponent<TipsGenerator>();

        if (autoFindItemShack)
        {
            itemShack = GameObject.Find("ItemShack").GetComponent<ItemShack>();
            autoFindWeaponShack = false;
        }
        else if (autoFindWeaponShack)
        {
            itemShack = GameObject.Find("Weapon Wheel").GetComponent<ItemShack>();
            autoFindItemShack = false;
        }
    }

    public void pickUpItem()
    {
        if(gameObject.GetComponent<TextClamp>() != null && GetComponent<TextClamp>().enabled)
        {
            gameObject.GetComponent<TextClamp>().disable();
        }

        itemShack.add(new Item(itemImage, itemTag, itemName, itemDesc));
        //tips.Show(messageOnPickUp);
        if (destroyOnPickUp)
            Destroy(gameObject);
        else
            gameObject.SetActive(false);
    }
}

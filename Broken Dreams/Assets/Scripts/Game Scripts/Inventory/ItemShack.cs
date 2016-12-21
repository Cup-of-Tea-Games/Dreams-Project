using UnityEngine;
using System.Collections;

public class ItemShack : MonoBehaviour
{

    const int SIZE = 18;
    public static int itemCount;

    void Awake()
    {
        itemCount = 0;
    }

    public Item[] items;

    public void remove(Item item)
    {
                item.delete();
                Debug.Log("Item Removed");      
    }
    public void add(Item item)
    {
          for (int i = 0; i < SIZE; i++)
        {
                  if (items[i].isEmpty())
              {
            items[i].setImage(item.getImage());
            items[i].setImageComponent(item.getImage());
            items[i].setitemName(item.getitemName());
            items[i].setDesc(item.getDesc());
            items[i].setTag(item.getTag());
            Debug.Log("Item Added");
            itemCount++;
                 break;
             }

            
        }

    }
}
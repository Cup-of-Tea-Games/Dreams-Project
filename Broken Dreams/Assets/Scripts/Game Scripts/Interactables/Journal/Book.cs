using UnityEngine;
using System.Collections;

public class Book : MonoBehaviour
{

    const int SIZE = 40;
    public static int PageCount;

    void Awake()
    {
        PageCount = 0;
    }

    public Page[] Pages;

    public void remove(Page Page)
    {
        Page.delete();
        Debug.Log("Page Removed");
    }
    public void add(Page Page)
    {
        for (int i = 0; i < SIZE; i++)
        {
            if (Pages[i].isEmpty())
            {
                Pages[i].setImage(Page.getImage());
                Pages[i].setImageComponent(Page.getImage());
                Pages[i].setPageName(Page.getPageName());
                Debug.Log("Page Added");
                PageCount++;
                break;
            }


        }

    }
}
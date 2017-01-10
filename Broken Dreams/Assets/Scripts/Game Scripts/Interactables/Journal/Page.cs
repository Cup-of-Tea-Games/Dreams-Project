using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Page : MonoBehaviour
{
    public Sprite emptyImage;
    protected Sprite image;
    protected string PageName;

    void Awake()
    {
    //    GetComponent<Image>().sprite = emptyImage;
    }

    public Page()
    {
        PageName = "";
        image = emptyImage;
    }

    public Page(Sprite aimage, string aName)
    {
        image = aimage;
        PageName = aName;
    }

    public Page(Page aPage)
    {
        image = aPage.image;
        PageName = aPage.PageName;
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

    public string getPageName()
    {
        return PageName;
    }

    public void setPageName(string s)
    {
        PageName = s;
    }

    public bool isEmpty()
    {
        return (PageName == "" && image == emptyImage);
    }

    public void delete()
    {
        setImage(emptyImage);
        PageName = "";
        setImageComponent(emptyImage);
    }

}

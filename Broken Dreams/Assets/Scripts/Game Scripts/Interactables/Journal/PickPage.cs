using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PickPage : MonoBehaviour {

    public Sprite displayImage;
    public Sprite pageImage;
    public PageViewer pageViewer;
    Page thisPage;
    Page displayPage;


    void Awake()
    {
        thisPage = new Page();
        thisPage.image = pageImage;
        displayPage = new Page();
        displayPage.image = displayImage;
    }

    public void viewPage()
    {
        PageViewer.displayPage = displayPage;
        PageViewer.pickedUpPage = thisPage;
        pageViewer.viewPage();
        PageViewer.paperInHand = this.gameObject;
    }
}

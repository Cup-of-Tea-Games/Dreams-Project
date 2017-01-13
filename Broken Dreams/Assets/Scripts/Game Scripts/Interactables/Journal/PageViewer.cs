using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PageViewer : MonoBehaviour {

    public static GameObject paperInHand;
    public static bool PageViewerIsUp;
    public static Page displayPage;
    public static Page pickedUpPage;
    public GameObject PageMenu;
    public GameObject PageDisplay;
    public Journal journal;

    GameObject tipsGen;
    TipsGenerator tips;

    void Awake()
    {
        displayPage = new Page();
        pickedUpPage = new Page();

        PageViewerIsUp = false;
        PageMenu.SetActive(false);
        tipsGen = GameObject.Find("ItemTips");
        tips = tipsGen.GetComponent<TipsGenerator>();
    }

    public void archivePage()
    {
        Destroy(paperInHand);
        paperInHand = null;
        PageViewerIsUp = false;
        tips.Show("Page Archived");
        PageMenu.SetActive(false);
        journal.add(pickedUpPage);
    }

    public void viewPage()
    {
        PageViewerIsUp = true;
        PageMenu.SetActive(true);
        PageDisplay.GetComponent<Image>().sprite = displayPage.getImage();
    }

    public void discardPage()
    {
        PageViewerIsUp = false;
        PageMenu.SetActive(false);
    }
}

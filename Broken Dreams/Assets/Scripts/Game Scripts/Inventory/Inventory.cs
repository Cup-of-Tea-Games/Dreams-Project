using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Inventory : MonoBehaviour {

    public int totalItems; //Index for the Item and ItemBase

    public GameObject[] itemBase;
    public GameObject[] item;

    public static int itemNum = 0;  //Item Number that represents the current inventory Selected Item

    public static bool[] active;
    public bool[] isActive;

    public Text ItemName;

    public static bool animProtecter; //Protects the animators from being interrupted

    public GameObject leftSmudge;

    void Awake() //Handles the assignment of the activation of items
    {
        itemEquipOnStart();

        delay1 = delay2 = true;
        animProtecter = true;
    }

    void Update()
    {
        checkActivation();
        if(!Raycast_Pickup.isGrabbing)
        Controls();
        ItemSearch();

        //Sets the current inventory number to text
    }

    void ItemSearch() //Uses ItemNum as reference to switch between items
    {
        if(animProtecter == true)
        switch (itemNum)
        {
            case 0:
                item[0].SetActive(true);
                item[1].SetActive(false);
                item[2].SetActive(false);
                    leftSmudge.SetActive(false);//Disable Item GUI
                    DisableItems();
                    ItemName.text = "";
                    break;

            case 1:
                item[0].SetActive(false);
                item[1].SetActive(true);
                item[2].SetActive(false);
                    leftSmudge.SetActive(true); //Enable Item GUI
                    ItemName.text = "Flashlight";
                    break;

            case 2:
                item[0].SetActive(false);
                item[1].SetActive(false);
                item[2].SetActive(true);
                    DisableItems();
                    ItemName.text = "Shotgun";
                    break;
        }
    }

    void Controls() //Switch between items
    {
        if (Input.GetKey("q") && delay1 == true && itemNum >= 1 && itemNum < 3)
        {
            delay1 = false;
            itemNum -= 1;
            StartCoroutine(DelayTime1());

        }
        else if (Input.GetKey("e") && delay2 == true && itemNum >= 0 && itemNum < 2)
        {
            delay2 = false;
            itemNum += 1;
            StartCoroutine(DelayTime2());
        }
    }

    void checkActivation() //Checks if the items are activated or not
    {
        for (int i = 0; i < totalItems; i++)
        {
            if (active[i] == true)
            {
                itemBase[i].SetActive(true);
            }
            else
                itemBase[i].SetActive(false);
        }
    }

    void itemEquipOnStart()
    {
        for(int i = 0; i < totalItems; i++)
        {
            active[i] = isActive[i];
        }
    } //Equipper

    bool delay1, delay2; //Acts as delays for the number switch

    public IEnumerator DelayTime1() //Used to create a certain delay
    {
        yield return new WaitForSeconds(0.25f);
        StopCoroutine(DelayTime1());
        delay1 = true;
    }

    public IEnumerator DelayTime2() //Used to create a certain delay
    {
        yield return new WaitForSeconds(0.25f);
        StopCoroutine(DelayTime2());
        delay2 = true;
    }

    void DisableItems() //Disables extras belonging to other items to ensure proper item switching
    {
        Flashlight.isEnabled = true;

    }
}

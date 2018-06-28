using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Selector : MonoBehaviour {

    public ItemShack itemShack;
    public InventoryMenu InventoryMenu;
    public static Item selectedItem;
    public static Main_Item selectedMain;

    //ToolTip
    public Image tipBase;
    public Text tipName;
    public Text tipDesc;
    public GameObject tipButtonUse;
    public GameObject tipButtonDiscard;
    public ToolTipMover toolTip;

    public Color32 healthItemColor;
    public Color32 sanityItemColor;
    public Color32 lightItemColor;

    //Items to Replenish
    public MeleeWeapon Pipe;
    public Flashlight BlackFlashlight;
    public Handgun G17;

    //Tools & Activators
    bool hasItemSelected = false;

    void Awake()
    {
        tipButtonDiscard.SetActive(false);
        tipButtonUse.SetActive(false);
        toolTip.enabled = true;
    }

    void Update()
    {
        if (!selectedItem.isEmpty() && selectedItem != null)
            showToolTip_ITEM();
    }

    public void showToolTip_ITEM()
    {
        if (!selectedItem.isEmpty())
        {
            tipBase.enabled = true;
            tipName.enabled = true;
            tipDesc.enabled = true;
            tipName.text = selectedItem.getitemName();
            tipDesc.text = selectedItem.getDesc();
           // colorManager();
        }
    }

    public void showToolTip_MAIN()
    {
        tipBase.enabled = true;
        tipName.enabled = true;
        tipDesc.enabled = true;


        if (selectedMain.getTag() == "Sanity_MAIN")
        {
            tipDesc.text = "Mentality " + PlayerSanity.sanity + "%";
            tipName.text = "Mind";
        }
        else if (selectedMain.getTag() == "Health_MAIN")
        {
            int healthLevel = (int) PlayerHealth.health;
            tipDesc.text =  "Vital Level " + healthLevel + "%";
            tipName.text = "Health";
        }
        else
        {
            Debug.Log(selectedMain.getTag());
        }

       // colorManager();
    }

    public void hideToolTip()
    {
        if (!hasItemSelected)
        {
            tipBase.enabled = false;
            tipName.enabled = false;
            tipDesc.enabled = false;
            tipName.text = "";
            tipDesc.text = "";
            selectedItem = new Item();
            tipButtonDiscard.SetActive(false);
            tipButtonUse.SetActive(false);
        }
    }

    public void useItem()
    {
        if (!selectedItem.isEmpty())
        {
            if (selectedItem.getitemName() == "Candy Bars")
            {
                if (PlayerHealth.health < 100)
                {
                    itemShack.remove(selectedItem);
                    hideToolTip();
                    PlayerHealth.health += 10;
                }
            }

            else if (selectedItem.getitemName() == "Brain")
            {
                if (PlayerSanity.sanity < 100)
                {
                    itemShack.remove(selectedItem);
                    hideToolTip();
                    PlayerSanity.sanity += 25;
                }
            }

            else if (selectedItem.getTag().Contains("Key"))
            {
                Raycast_Pickup.itemInMyHand = selectedItem;
                InventoryMenu.inventroyIsUp = false;
                WeaponWheel.selectItemExternal(0);
                hideToolTip();
            }

            else if (selectedItem.getTag().Contains("Replenish"))
            {
                    if (selectedItem.getTag().Contains("G17"))
                    {
                    itemShack.remove(selectedItem);
                    G17.addAmmo(1);
                    }
                    else if (selectedItem.getTag().Contains("Flashlight"))
                    {
                    itemShack.remove(selectedItem);
                    BlackFlashlight.addBatteries(1);
                    }

                hideToolTip();
            }

            //Resets Buttons
            resetSelection();
            InventoryMenu.objectsFadeOut();
            //End of Statement
        }
    }

    public void discardItem()
    {
        if (!selectedItem.isEmpty())
        {

            itemShack.remove(selectedItem);
            resetSelection();
            //End of Statement
        }
    }

    public void resetSelection()
    {
        if (hasItemSelected)
        {
            hideToolTip();
            hasItemSelected = false;
            toolTip.enabled = true;
            tipButtonDiscard.SetActive(false);
            tipButtonUse.SetActive(false);
        }
    }

    public void selectItem()
    {
        if (!selectedItem.isEmpty() && selectedItem != null)
        {
            if(!selectedItem.getTag().Contains("Key"))
            tipButtonDiscard.SetActive(true);

            tipButtonUse.SetActive(true);
            toolTip.enabled = false;
            hasItemSelected = true;
            Input.mousePosition.Set(tipButtonUse.transform.position.x, tipButtonUse.transform.position.y , tipButtonUse.transform.position.z);
        }
    }

    void colorManager()
    {
        if (selectedItem.getTag() == "Health" || selectedMain.getTag() == "Health_MAIN")
            tipDesc.color = healthItemColor;
        else if (selectedItem.getTag() == "Sanity" || selectedMain.getTag() == "Sanity_MAIN")
            tipDesc.color = sanityItemColor;
        else if (selectedItem.getTag() == "Light" || selectedMain.getTag() == "Light_MAIN")
            tipDesc.color = lightItemColor;
        else
            tipDesc.color = Color.gray;
            
    }
}

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class SelectorWeapons : MonoBehaviour
{

    public ItemShack itemShack;
    public static Item selectedItem;
    public static Main_Item selectedMain;

    //ToolTip
    public Text tipName;
    public Text tipDesc;

    void Update()
    {
        if (selectedItem != null && !selectedItem.isEmpty())
            showToolTip_ITEM();
    }

    public void showToolTip_ITEM()
    {
        if (!selectedItem.isEmpty())
        {
            tipName.enabled = true;
            tipName.text = selectedItem.getitemName();
            tipDesc.text = selectedItem.getDesc();
            // colorManager();
        }
    }

    public void hideToolTip()
    {
        tipName.enabled = false;
        tipName.text = "";
        tipDesc.text = "";
        selectedItem = new Item();
    }

    public void useItem()
    {
            if (selectedItem.getTag() == "Flashlight")
            {
                WeaponWheel.selectItemExternal(1);
                WeaponWheel.currentWeapon = selectedItem;
            }
            else if (selectedItem.getTag() == "Hand")
            {
                WeaponWheel.selectItemExternal(0);
                WeaponWheel.currentWeapon = selectedItem;
            }

            else if (selectedItem.getTag() == "Pipe")
            {
                WeaponWheel.selectItemExternal(2);
                WeaponWheel.currentWeapon = selectedItem;
            }
            else if (selectedItem.getTag() == "Handgun")
            {
                WeaponWheel.selectItemExternal(3);
                WeaponWheel.currentWeapon = selectedItem;
            }

        else if (selectedItem.getTag() == "BoneSaw")
        {
            WeaponWheel.selectItemExternal(4);
            WeaponWheel.currentWeapon = selectedItem;
        }
    }
    

}

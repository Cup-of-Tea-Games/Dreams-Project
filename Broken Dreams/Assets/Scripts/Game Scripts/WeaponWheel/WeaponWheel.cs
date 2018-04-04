using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;

public class WeaponWheel : MonoBehaviour {

    public GameObject weaponSelector;
    public ItemShack weaponShack;
    public GameObject transformBall;
    public Unarmed handsAnimation;
    public Animator handsAnimator;
    public static bool isShowing = false;
    public GameObject[] weapons;
    public GameObject[] weaponPrefabs;
    public RuntimeAnimatorController[] weaponAnimationControllers;
    public static int numSwitch = 0;
    public static bool activeExternal = false;
    public static Item currentWeapon;

    List<int> slots = new List<int>();
    int slotNumber = 0;

    void Update()
    {

        slotNumber = Mathf.Clamp(slotNumber, 0, slots.Count);

        if (Input.GetKey(KeyCode.E))
        {
            weaponSelector.SetActive(true);
            isShowing = true;
            Time.timeScale = 0.2f;
        }
        else if (!InventoryMenu.PauseIsUp)
        {
            weaponSelector.SetActive(false);
            isShowing = false;
            Time.timeScale = 1f;
        }

        if (Input.GetKeyDown(KeyCode.Q))
        {
            throwItem();
        }

        //This is for other scripts to switch weapons
        if (activeExternal)
        {
            selectItem(numSwitch);
            activeExternal = false;
        }

        //Functionality
        quickSelectItem();
        calculateNextAvailableSlot();
    }

    public void selectItem(int x)
    {
        for(int i = 0; i < weapons.Length; i++)
        {
            if (weapons[i].activeSelf && i != x)
            {
                weapons[i].SetActive(false);
            }
        }
        weapons[x].SetActive(true);
        handsAnimator.runtimeAnimatorController = weaponAnimationControllers[x];
    }

    void quickSelectItem()
    {

        if (Input.GetAxis("Mouse ScrollWheel") > 0f) // forward
        {
            if (slotNumber < slots.Count)
            {
                slotNumber++;
                selectItemExternal(slots[slotNumber]);
            }
        }
        else if (Input.GetAxis("Mouse ScrollWheel") < 0f) // backwards
        {
            if (slotNumber > 0)
            {
                slotNumber--;
                selectItemExternal(slots[slotNumber]);
            }
            else
                selectItem(0);
        }

        for (int i = 0; i < slots.Count; i++)
        {
            if(slots[i] != null)
            Debug.Log(slots[i]);
        }


      //  weapons[x].SetActive(true);
    //    handsAnimator.runtimeAnimatorController = weaponAnimationControllers[x];
    }

    public void calculateNextAvailableSlot()
    {
        slots.Clear();

        for (int i = 0; i < weapons.Length; i++)
        {
            for (int k = 0; k < weaponShack.items.Length; k++)
            {
                if(weaponShack.get(k).getitemName() == weapons[i].name)
                {
                    slots.Add(i);
                }
            }
        } //For
    }

    public static void selectItemExternal(int x)
    {
        numSwitch = x;
        activeExternal = true;
    }

    void throwItem()
    {
        GameObject clone = new GameObject();
        clone = Instantiate(weaponPrefabs[numSwitch]);
        clone.transform.position = transformBall.transform.position;
        clone.GetComponent<Rigidbody>().AddForce(transformBall.transform.forward * 2000);
        if(currentWeapon.getTag() != "Hand")
        weaponShack.remove(currentWeapon);
        selectItemExternal(0);
        handsAnimation.tossItem();
       // currentWeapon = weaponShack.get(0);

    }

    public void removeItem()
    {
        if (currentWeapon.getTag() != "Hand")
            weaponShack.remove(currentWeapon);

        selectItemExternal(0);
        // currentWeapon = weaponShack.get(0);

    }
}

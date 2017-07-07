using UnityEngine;
using System.Collections;
using System;

public class WeaponWheel : MonoBehaviour {

    public GameObject weaponSelector;
    public ItemShack weaponShack;
    public GameObject transformBall;
    public static bool isShowing = false;
    public GameObject[] weapons;
    public GameObject[] weaponPrefabs;
    public static int numSwitch = 0;
    public static bool activeExternal = false;
    public static Item currentWeapon;

    void Update()
    {
        if (Input.GetKey(KeyCode.E))
        {
            weaponSelector.SetActive(true);
            isShowing = true;
        }
        else
        {
            weaponSelector.SetActive(false);
            isShowing = false;
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
    }

    public void selectItem(int x)
    {
        for(int i = 0; i < weapons.Length; i++)
        {
            if (weapons[i].activeSelf && i != x)
                weapons[i].SetActive(false);
        }
        weapons[x].SetActive(true);
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

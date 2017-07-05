using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Wallpaper : MonoBehaviour {

    public Sprite[] images;
	// Update is called once per frame
	void Update () {
        GetComponent<Image>().sprite = images[PlayerPrefs.GetInt("Wallpaper")];
	}

    public void setImage(int i)
    {
        PlayerPrefs.SetInt("Wallpaper", i);
    }
}

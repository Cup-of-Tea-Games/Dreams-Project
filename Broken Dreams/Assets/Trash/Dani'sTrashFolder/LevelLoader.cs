using UnityEngine;
using System.Collections;

public class LevelLoader : MonoBehaviour {

    public void restartLevel()
    {
        Application.LoadLevel(Application.loadedLevelName);
    }

    public void goToLevel(string s)
    {
        InventoryMenu.inventroyIsUp = false;
        Application.LoadLevel(s);

    }

    public void exitApplication()
    {
        Application.Quit();

    }
}

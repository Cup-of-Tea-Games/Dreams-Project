using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class InstantLevelTransfer : MonoBehaviour {

    public string levelToWarp;

	void Start () {
        SceneManager.LoadScene(levelToWarp);
	}
}

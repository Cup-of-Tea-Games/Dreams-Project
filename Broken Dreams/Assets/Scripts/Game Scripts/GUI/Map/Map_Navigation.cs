using UnityEngine;
using System.Collections;
using UnityStandardAssets.Utility;

public class Map_Navigation : MonoBehaviour {

    private Camera mapCamera;
    public SmoothFollow follower;

	// Use this for initialization
	void Start () {
        mapCamera = GetComponent<Camera>();
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.D))
        {
            follower.enabled = false;

            if (Input.GetKey(KeyCode.A))
                mapCamera.transform.position += new Vector3(-1, 0, 0);

            if (Input.GetKey(KeyCode.D))
                mapCamera.transform.position += new Vector3(1, 0, 0);

            if (Input.GetKey(KeyCode.W))
                mapCamera.transform.position += new Vector3(0, 0, 1);

            if (Input.GetKey(KeyCode.S))
                mapCamera.transform.position += new Vector3(0, 0, -1);
        }
	}

    void OnEnable()
    {
        follower.enabled = true;
    }
}

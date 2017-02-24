using UnityEngine;
using System.Collections;

public class Drawer : MonoBehaviour {

    public Transform originalPos;
    public Transform nextPos;
    bool toggle = false;

    void Update()
    {
        if (!toggle)
            gameObject.transform.position = Vector3.Lerp(gameObject.transform.position, originalPos.position, 7 * Time.deltaTime);
        else
            gameObject.transform.position = Vector3.Lerp(gameObject.transform.position, nextPos.position, 7 * Time.deltaTime);

    }
    public void move()
    {
        toggle = !toggle;
    }
}

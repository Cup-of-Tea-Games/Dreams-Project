using UnityEngine;
using System.Collections;

public class Face : MonoBehaviour {

    public Page page1;
    public Page page2;

    public bool isEmpty()
    {
        return (page1.isEmpty() && page2.isEmpty());
    }
}

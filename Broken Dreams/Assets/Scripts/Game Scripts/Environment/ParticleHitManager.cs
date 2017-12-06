using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct MaterialObject
{
    public string materialTagName;
    public AudioClip materialHitSound;
    public GameObject particleEffect;
    public GameObject decal;

}

public class ParticleHitManager : MonoBehaviour {

    public MaterialObject[] materialObjects;

    public MaterialObject getMaterialObject(string s)
    {
        MaterialObject temp = new MaterialObject();
        string x = "";
        for(int i = 0; i < materialObjects.Length; i++)
        {
            if(materialObjects[i].materialTagName == s)
                return materialObjects[i];
                
        }
        return temp;
    }
}

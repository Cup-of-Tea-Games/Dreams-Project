using UnityEngine;
using System.Collections;

public class Journal : MonoBehaviour
{
    public GameObject BookFront;
    bool isOnFront;
    public GameObject BookPages;
    public GameObject BookBack;
    bool isOnBack;
    private int currentFace;
    public int totalFaces;
    public Face[] faces;

    void Awake()
    {
        currentFace = 0;
        closeBook();

        for(int i = 0; i < totalFaces; i++)
        {
            if (faces[i].page1.startEmpty)
                faces[i].page1.delete();

            else if (faces[i].page2.startEmpty)
                faces[i].page2.delete();
        }
    }

    public void nextPage()
    {
        if (!faces[currentFace].page2.isEmpty() && (!faces[currentFace + 1].page1.isEmpty()))
        {
            if(isOnFront)
            isOnFront = false;
            else
            currentFace += 1;


        }
        else
            finishBook();
    }

    public void previousPage()
    {
        if (!isOnFront)
            if (currentFace == 0)
                closeBook();
            else if (!isOnBack)
            {
                currentFace -= 1;
                faces[currentFace + 1].gameObject.SetActive(false);
            }

            else
            {
                isOnBack = false;
                BookBack.SetActive(false);
            }
    }

    public void closeBook()
    {
        isOnFront = true;
        isOnBack = false;
        currentFace = 0;
    }

    public void finishBook()
    {
        isOnBack = true;
        isOnFront = false;
    }

    void Update()
    {
        if (isOnFront)
        {
            BookFront.SetActive(true);
            BookBack.SetActive(false);
            BookPages.SetActive(false);
        }
        else if (isOnBack)
        {
            BookFront.SetActive(false);
            BookBack.SetActive(true);
            BookPages.SetActive(false);
        }
        else
        {
            BookPages.SetActive(true);
        }

  //      Debug.Log(currentFace);

        if(!isOnFront && !isOnBack)
        faces[currentFace].gameObject.SetActive(true);
        else
            faces[currentFace].gameObject.SetActive(false);
        if (!isOnFront)
        faces[currentFace - 1].gameObject.SetActive(false);
        if (!isOnBack)
            faces[currentFace + 1].gameObject.SetActive(false);
    }



    public void remove(Page Page)
    {
        Page.delete();
        Debug.Log("Page Removed");
    }



}
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityStandardAssets.Characters.FirstPerson;

public class Raycast_Pickup : MonoBehaviour
{
    public int distanceToItem; //Distance from item to trigger grabbing
    RaycastHit hit; //The Raycast itself
    public GameObject hand; //Hand GUI 
    public GameObject toggle; //Toggle GUI 
    public GameObject door; //Door GUI 
    public GameObject exit; //Exit GUI 
    public GameObject bed; //Bed GUI 
    public GameObject drawer; //Drawer GUI 
    public GameObject pcIcon; //PC GUI 
    public GameObject journal; //Journal GUI 
    public GameObject sit; //Sit GUI 
    public GameObject pickUp; //Pick Up GUI 
    public GameObject ItemInHand; //Item GUI
    public GameObject ladder; //Ladder GUI
    public GameObject hint; //Hint GUI
    public GameObject toggleswitch; //Hint GUI
    public static bool isLooking; //Determine if the player is looking at the object
    public static bool isGrabbing; //Determine if the player is grabbing the object
    public GameObject transformBall; //The imaginary ball in which the item picked up shall be in
    public static GameObject objectInstance; //The object that is being picked up
    public float speed; //The speed the object shall travel
    public float pushForce; //Force of which the player can push items
    private float mouseWheelAmount; //Records the amount of scrolls in the mouse wheel
    public static bool mouseClickToggle = false; //Toggles on or off on mouse click

    //GUI PROCESSING
    public TipsGenerator tips; //Tips Generator
    //Item in your hand
    public static Item itemInMyHand;

    //Misc
    bool delayTime = true; //Creates Time Delays when necesary
    float defaultValue; //Saves saved value for speed
    float rotateTimeSet = 2f; // This is specifically used for resetting object's rotation
    public static GameObject pickUpInstance;

    //Apartment
    public static GameObject chairInstance;
    int layerMask = ~(2 << 9);


    void Awake()
    {
        defaultValue = speed;
        itemInMyHand = new Item();
        isGrabbing = false;
    }

    void Update()
    {

        if (objectInstance == null || (isGrabbing && pickUpInstance != objectInstance))
            isGrabbing = false;

        if (Input.GetMouseButtonDown(0) && itemInRange() && !isGrabbing)
        {
            mouseClickToggle = !mouseClickToggle;
            PickUpItemClick();
        }
        if (!itemInRange() && pickUpInstance == null)
         mouseClickToggle = false;

     //   if (!isLooking && objectInstance != null)
     //       LetGoItem();

        if (itemInMyHand.isEmpty())
        {
            ItemInHand.SetActive(false);
        }
        else
        {
            ItemInHand.GetComponent<Image>().sprite = itemInMyHand.getImage();
            ItemInHand.SetActive(true);
        }

        //Checks if the Object is in Range to grab
        if (itemInRange() && !isGrabbing)
        {

         //   LetGoItem();
            if (!mouseClickToggle)
            {
                if (itemInMyHand.isEmpty())
                {
                    if (hit.collider.gameObject.tag == "Item" || hit.collider.gameObject.tag == "Page")
                        pickUp.SetActive(true);
                    else if (hit.collider.gameObject.tag == "pickUpObject" || hit.collider.gameObject.tag == "pickUpHeavyObject")
                        hand.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Door")
                        door.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Drawer")
                        drawer.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Sit Object" && hit.collider.gameObject.GetComponent<SitDown>().canSitDown)
                        sit.SetActive(true);
                    else if (hit.collider.gameObject.tag == "PC" && chairInstance.GetComponent<SitDown>().satDown)
                        pcIcon.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Toggle")
                        toggle.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Journal")
                        journal.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Exit")
                        exit.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Bed")
                        bed.SetActive(true);
                    else if (hit.collider.gameObject.tag == "KeyReciever")
                        hint.SetActive(true);
                    else if (hit.collider.gameObject.tag == "Switch")
                        toggleswitch.SetActive(true);

                    if (!FirstPersonController.isClimbing)
                    {
                        if (hit.collider.gameObject.tag == "Ladder")
                            ladder.SetActive(true);
                    }
                    else
                    {
                        ladder.SetActive(false);
                        hand.SetActive(false);
                        pickUp.SetActive(false);
                        door.SetActive(false);
                        sit.SetActive(false);
                        pcIcon.SetActive(false);
                        toggle.SetActive(false);
                        drawer.SetActive(false);
                        journal.SetActive(false);
                        exit.SetActive(false);
                        bed.SetActive(false);
                        hint.SetActive(false);
                        toggleswitch.SetActive(false);
                    }
                }


                ResetZoom();
            }
        }
        else
        {
            ladder.SetActive(false);
            hand.SetActive(false);
            pickUp.SetActive(false);
            door.SetActive(false);
            sit.SetActive(false);
            pcIcon.SetActive(false);
            toggle.SetActive(false);
            drawer.SetActive(false);
            journal.SetActive(false);
            exit.SetActive(false);
            bed.SetActive(false);
            hint.SetActive(false);
            toggleswitch.SetActive(false);
            ItemInHand.GetComponent<Image>().color = new Color32(255, 255, 255, 055);

        }

        //Patch for Multiple Images Appearing at once

        if (hand.active && ((hit.collider.gameObject.tag == "pickUpObject" || hit.collider.gameObject.tag == "pickUpHeavyObject") || hit.collider.gameObject.tag == "Sit Object" && hit.collider.gameObject.GetComponent<SitDown>().canSitDown))
        {
            ladder.SetActive(false);
            pickUp.SetActive(false);
            door.SetActive(false);
            pcIcon.SetActive(false);
            toggle.SetActive(false);
            drawer.SetActive(false);
            journal.SetActive(false);
            hint.SetActive(false);
            toggleswitch.SetActive(false);
        }
        else
        {
            hand.SetActive(false);
        }

        //Grabs Item
        if (itemInRange() && mouseClickToggle)
        {
            if (delayTime == true)
                PickUpItemToggle();
            hand.SetActive(false);
            pickUp.SetActive(false);

        }

        if (itemInRange() && Input.GetMouseButton(0) && !mouseClickToggle)
        {
            if (delayTime == true)
                PickUpItemClick();
            hand.SetActive(false);
            pickUp.SetActive(false);
        }

      if (mouseClickToggle && pickUpInstance != null)
        {
            if (delayTime == true)
               PickUpToggle();
           hand.SetActive(false);
            pickUp.SetActive(false);

        }

        if (itemInRange() && Input.GetMouseButtonDown(1))
        {
            ThrowItem();
            hand.SetActive(false);
            pickUp.SetActive(false);
            mouseClickToggle = false;
            pickUpInstance = null;
            isGrabbing = false;
        }

        //Throw Item
        if (itemInRange() && Input.GetMouseButton(0) && Input.GetMouseButtonDown(1))
        {
            ThrowItem();
            mouseClickToggle = false;
        }
        if (!mouseClickToggle && pickUpInstance != null)
        {
           LetGoItem();
            pickUpInstance = null;
        }
        //Makes sure your held item is not there when you mistakenly click on something irrelevant
        KeyManager();
    }

    void KeyManager()
    {
        if (itemInRange() && objectInstance.GetComponent<Door>() != null && hit.collider.gameObject.tag == "Door")
        {
            ItemInHand.GetComponent<Image>().color = new Color32(255, 255, 255, 255);

            if (Input.GetMouseButton(0))
            {
                if (itemInMyHand.isEmpty())
                {
                    if (objectInstance.GetComponent<Door>().isLocked)
                        tips.Show("Door is Locked");
                }
                else
                {
                    if (objectInstance.GetComponent<Door>().keyTag == itemInMyHand.getTag())
                    {
                        itemInMyHand.delete();
                        tips.Show("Door is Now Open");
                        objectInstance.GetComponent<Door>().unlockDoor();
                    }
                    else
                    {
                        itemInMyHand = new Item();
                        tips.Show("Wrong Key");
                    }
                }
            }
        }

        if (itemInRange() && objectInstance.GetComponent<KeyReciever>() != null)
        {
      //      Debug.Log("MOUSffdfdfdE");
            ItemInHand.GetComponent<Image>().color = new Color32(255, 255, 255, 255);
            if (Input.GetMouseButton(0))
            {
           //     Debug.Log("MOUSE");
                if (itemInMyHand.isEmpty())
                {
              //      Debug.Log("IF");
                    objectInstance.GetComponent<KeyReciever>().investigate();
                }
                else
                {
                //    Debug.Log("ELSE");
                    objectInstance.GetComponent<KeyReciever>().insertKey(itemInMyHand.getTag());
                    if(objectInstance.GetComponent<KeyReciever>().isRecieved())
                    itemInMyHand.delete();

                }
            }
        }


        else if (!itemInMyHand.isEmpty() && Input.GetMouseButton(0) && !itemInRange())
        {
            itemInMyHand = new Item();
        }

    }

    bool itemInRange()
    {
        bool active = false;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray, out hit, distanceToItem))
        {
            if (hit.collider.gameObject.tag == "pickUpHeavyObject" || hit.collider.gameObject.tag == "pickUpObject" || hit.collider.gameObject.tag == "Door" || hit.collider.gameObject.tag == "Item" || hit.collider.gameObject.tag == "Ladder" || hit.collider.gameObject.tag == "Page" || hit.collider.gameObject.tag == "Sit Object" || hit.collider.gameObject.tag == "PC" || hit.collider.gameObject.tag == "Toggle" || hit.collider.gameObject.tag == "Drawer" || hit.collider.gameObject.tag == "Journal" || hit.collider.gameObject.tag == "Exit" || hit.collider.gameObject.tag == "Bed" || hit.collider.gameObject.tag == "IgnoreRay" || hit.collider.gameObject.tag == "KeyReciever" || hit.collider.gameObject.tag == "Switch")
            {
                active = true;
                objectInstance = hit.collider.gameObject;
                if(hit.collider.gameObject.tag != "pickUpObject")
                pickUpInstance = null;

                if (hit.collider.gameObject.tag == "Sit Object" || hit.collider.gameObject.tag == "Bed")
                {
                    chairInstance = hit.collider.gameObject;
                }
                else if (hit.collider.gameObject.tag == "IgnoreRay")
                {
                    Physics.IgnoreCollision(hit.collider, hit.collider.gameObject.GetComponent<Collider>());
                }
            }

            else if (hit.collider.gameObject.tag == "Ladder")
            {
                if (objectInstance.GetComponent<Ladder>() != null)
                {
                    FirstPersonController.ladder = objectInstance.GetComponent<Ladder>();
                    FirstPersonController.ladder.enabled = true;
                }
            }


            if (hit.collider.gameObject.tag == "pickUpObject" && pickUpInstance != hit.collider.gameObject)
            {
                GameObject newObject = hit.collider.gameObject;
                pickUpInstance = newObject;
            }
        }
        isLooking = active;
        return active;

    }

    void PickUpItemToggle()
    {
        if (hit.collider.gameObject.tag == "pickUpObject")
        {
            isGrabbing = true;
            if (!objectInstance.GetComponent<ObjectStabilizer>().isOnCollision())
            {
                objectInstance.transform.position = Vector3.Lerp(objectInstance.transform.position, transformBall.transform.position, speed * Time.deltaTime);
              //  Debug.Log("NOT COLLIDING");
            }
            else
            {
                objectInstance.transform.position = Vector3.Slerp(objectInstance.transform.position, transformBall.transform.position, speed * Time.deltaTime / 12f);
              //  Debug.Log("COLLIDING");
            }                //    objectInstance.transform.rotation = new Quaternion(transformBall.transform.rotation.x, transformBall.transform.rotation.y, objectInstance.transform.rotation.z, objectInstance.transform.rotation.w);
            objectInstance.GetComponent<Rigidbody>().freezeRotation = true;
            objectInstance.GetComponent<Rigidbody>().useGravity = false;
        }
        else if (hit.collider.gameObject.tag == "pickUpHeavyObject")
        {
            objectInstance.transform.position = Vector3.MoveTowards(objectInstance.transform.position, transformBall.transform.position, (speed / 30) * Time.deltaTime);
        }


        else if (hit.collider.gameObject.tag == "Toggle")
        {
            objectInstance.GetComponent<Toggle>().toggle();
            StartCoroutine(delaySeconds(1f));
            mouseClickToggle = false;
        }

        else if (hit.collider.gameObject.tag == "Drawer")
        {
            objectInstance.GetComponent<Drawer>().move();
            StartCoroutine(delaySeconds(1f));
            mouseClickToggle = false;
        }


        else if (hit.collider.gameObject.tag == "Sit Object" && hit.collider.gameObject.GetComponent<SitDown>().canSitDown)
        {
            SitDown.sitDown = true;
            mouseClickToggle = false;
        }


        ZoomAbility(); //Gives the Player the Ability to Zoom
        RotateAbility(); //Gives the Player the Ability to rotate

        //Failsafe for object impact
        if (objectInstance.GetComponent<Collider>().tag == "Untagged")
            speed = 5;
        else
            speed = defaultValue;
    }

    void PickUpToggle()
    {     
            isGrabbing = true;
            if (!pickUpInstance.GetComponent<ObjectStabilizer>().isOnCollision())
            {
            pickUpInstance.transform.position = Vector3.Lerp(pickUpInstance.transform.position, transformBall.transform.position, speed * Time.deltaTime);
                //  Debug.Log("NOT COLLIDING");
            }
            else
            {
            pickUpInstance.transform.position = Vector3.Slerp(pickUpInstance.transform.position, transformBall.transform.position, speed * Time.deltaTime / 12f);
                //  Debug.Log("COLLIDING");
            }                //    objectInstance.transform.rotation = new Quaternion(transformBall.transform.rotation.x, transformBall.transform.rotation.y, objectInstance.transform.rotation.z, objectInstance.transform.rotation.w);
        pickUpInstance.GetComponent<Rigidbody>().freezeRotation = true;
        pickUpInstance.GetComponent<Rigidbody>().useGravity = false;
    }

    void PickUpItemClick()
    {

        if (hit.collider.gameObject.tag == "Door")
        {
            if (objectInstance.GetComponent<Door>() != null && delayTime)
            {
                objectInstance.GetComponent<Door>().toggle();
                delayTime = false;
            }

            StartCoroutine(delaySeconds(1f));
            mouseClickToggle = false;

        }

        else if (hit.collider.gameObject.tag == "PC" && chairInstance.GetComponent<SitDown>().satDown)
        {
            Computer.isOnPC = true;
            mouseClickToggle = false;
        }

        else if (hit.collider.gameObject.tag == "Journal")
        {
            objectInstance.GetComponent<PhysicalJournal>().displayJournal();
            mouseClickToggle = false;
        }

        else if (hit.collider.gameObject.tag == "Exit")
        {
            objectInstance.GetComponent<Exit>().showMessage();
            mouseClickToggle = false;
        }

        else if (hit.collider.gameObject.tag == "Item")
        {
         //   Debug.Log("APAPAPAPAPAPAP");
            objectInstance.GetComponent<PickItem>().pickUpItem();
        }

        else if (hit.collider.gameObject.tag == "Page")
        {
            objectInstance.GetComponent<PickPage>().viewPage();
        }


        else if (hit.collider.gameObject.tag == "Switch")
        {
            if(objectInstance.GetComponent<Lever>() != null)
            {
                objectInstance.GetComponent<Lever>().activate();
            }
            if (objectInstance.GetComponent<Button>() != null)
            {
                objectInstance.GetComponent<Button>().activate();
            }

            if (objectInstance.GetComponent<ButtonSimple>() != null)
            {
                objectInstance.GetComponent<ButtonSimple>().activate();
            }
        }

        else if (hit.collider.gameObject.tag == "Ladder")
        {
            if (objectInstance.GetComponent<Ladder>() != null)
            {
                FirstPersonController.ladder = objectInstance.GetComponent<Ladder>();
                FirstPersonController.isClimbing = true;
                objectInstance = null;
            }
        }

        //Native Code ------------------------------------------------------------------------------------------------------------------------------



        //Apartment Code

        else if (hit.collider.gameObject.tag == "Bed")
        {
            Bed.sitDown = true;
            StartCoroutine(delaySeconds(4f));
            mouseClickToggle = false;
        }

        ZoomAbility(); //Gives the Player the Ability to Zoom
        RotateAbility(); //Gives the Player the Ability to rotate

        //Failsafe for object impact
        if (objectInstance.GetComponent<Collider>().tag == "Untagged")
            speed = 5;
        else
            speed = defaultValue;
    }

    public static void LetGoItem()
    {
        objectInstance.GetComponent<Rigidbody>().useGravity = true;
        objectInstance.GetComponent<Rigidbody>().freezeRotation = false;
        //isGrabbing = false;
        if (pickUpInstance != null)
        {
            pickUpInstance.GetComponent<Rigidbody>().useGravity = true;
            pickUpInstance.GetComponent<Rigidbody>().freezeRotation = false;
        }

    }

    void ThrowItem()
    {
        delayTime = false;
        LetGoItem();

        if (hit.collider.gameObject.tag == "pickUpObject" || hit.collider.gameObject.tag == "pickUpHeavyObject")
            objectInstance.GetComponent<Rigidbody>().AddForce(transformBall.transform.TransformDirection(Vector3.forward) * 500);
        else if (hit.collider.gameObject.tag == "pickUpObject" || hit.collider.gameObject.tag == "pickUpHeavyObject")
            objectInstance.GetComponent<Rigidbody>().AddForce(transformBall.transform.TransformDirection(Vector3.forward) * 500 / 2);

        StartCoroutine(delaySeconds(1f));
    }

    void ZoomAbility()
    {
        float originalBallPosition = 1.14531f;
        mouseWheelAmount += Input.GetAxis("Mouse ScrollWheel") * 2;
        mouseWheelAmount = Mathf.Clamp(mouseWheelAmount, -0.25f, 1.0f);

        if (isGrabbing)
            transformBall.transform.localPosition = new Vector3(-0.6657115f, 0.35004f, originalBallPosition + mouseWheelAmount + objectInstance.GetComponent<ObjectStabilizer>().grabOffset);

    }

    void RotateAbility()
    {
        //  transformBall.transform.rotation = objectInstance.transform.rotation;
        if (Input.GetKey(KeyCode.R))
        {
            objectInstance.transform.Rotate(Input.GetAxis("Mouse Y"), Input.GetAxis("Mouse X"), 0, Space.Self);

            if (rotateTimeSet <= rotateTimeSet - 1f)
                objectInstance.transform.rotation = Quaternion.Euler(0, 0, 0);
        }

        if (Input.GetKeyUp(KeyCode.R))
        {
            rotateTimeSet = Time.time;
//Debug.Log(rotateTimeSet);
        }
    }

    void ResetZoom()
    {
        float originalBallPosition = 1.14531f;
        mouseWheelAmount = 0;
        transformBall.transform.localPosition = new Vector3(-0.6657115f, 0.35004f, originalBallPosition);
    }

    public IEnumerator delaySeconds(float x)
    {
        ladder.SetActive(false);
        hand.SetActive(false);
        pickUp.SetActive(false);
        door.SetActive(false);
        sit.SetActive(false);
        pcIcon.SetActive(false);
        toggle.SetActive(false);
        drawer.SetActive(false);
        yield return new WaitForSeconds(x);
        delayTime = true;
        StopCoroutine(delaySeconds(x));
    }
}


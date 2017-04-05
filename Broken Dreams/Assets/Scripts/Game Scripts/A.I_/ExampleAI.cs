using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;

public class ExampleAI : MonoBehaviour
{

    //Worst Case Scenario, the inclusion of the aypoints may require the Navigation Mesh to be rebaked.

    private bool chase = false;
    private bool patrol = true;
    private bool active = true;
    private bool outOfSight = true;
    private bool isOnWaypoint = false;
    private int waypointCount = 0;
    private int currentWaypoint = 0;
    private NavMeshAgent agent;
    private float lostValue;

    public Transform target;
    public Collider AIFOV;
    public Animator animator;
    public Transform[] waypoints;
    public float destinationResetTime = 1.0f;
    public Collider hitBox;
    public Collider AIAttackRange;


    void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
        waypointCount = waypoints.Length;
        changeWaypoint();
    }

    void Update()
    {
        //  Debug.Log("IS on Waypoint: " + isOnWaypoint);
        Debug.Log(lostValue);
        if (outOfSight)
            lostValue = 0;
        else
            lostValue += 0.01f;

        if (chase)
        {
            agent.speed = 4;
            AIFOV.enabled = false;
            AIAttackRange.enabled = true;
        }
        else
        {
            agent.speed = 1.5f;
            AIFOV.enabled = true;
            AIAttackRange.enabled = false;
        }

        if (chase && !patrol && active)
        {
            StartCoroutine(chaseTarget());
        }

        else if (patrol && !chase && active)
        {
            StartCoroutine(patrolRoom());
        }
    }

    IEnumerator chaseTarget()
    {

    /*    if (outOfSight)
        {
          //  Debug.Log("DONT SEE YOU");
            agent.SetDestination(target.position);
            yield return WaitForSecondsOrTap(0f);
          //  Debug.Log("LOST YOU");
            chase = false;
            patrol = true;
            StopCoroutine(chaseTarget());
        }*/


        animator.Play("Run");
        yield return new WaitForSeconds(0);
        agent.SetDestination(target.position);
       // active = true;
        StopCoroutine(chaseTarget());
    }

    IEnumerator attack()
    {
        agent.Stop();
        active = false;
        animator.CrossFade("Attack", 0.3f);
        yield return new WaitForSeconds(0.7f);
        hitBox.enabled = true;
        yield return new WaitForSeconds(2f);
        hitBox.enabled = false;
        agent.Resume();
       // yield return new WaitForSeconds(1f);
        active = true;
        StopCoroutine(attack());
    }

    IEnumerator patrolArea()
    {
        //animator.CrossFade("Walk");
        yield return new WaitForSeconds(2f);
        agent.Stop();
     //   Debug.Log("Patrol Stopped");
        //animator.CrossFade("Idle");
        int newWaypoint = Random.RandomRange(0, waypointCount);
        agent.SetDestination(waypoints[newWaypoint].position);
        agent.Resume();
        yield return new WaitForSeconds(2f);
        active = true;
        //Debug.Log("Patrol Continued");
        StopCoroutine(patrolArea());
    }

    IEnumerator patrolRoom()
    {
        float distance = Vector3.Distance(agent.transform.position, waypoints[currentWaypoint].position);

       if (distance < 1f)
        {
            if (!chase)
            {
                active = false;
                animator.CrossFade("Idle", 1f);
                yield return new WaitForSeconds(6f);
                active = true;
            }
        }
        if (agent.transform.position != waypoints[currentWaypoint].position)
        {
            if (!chase && active)
            {
                animator.CrossFade("Walk", 0f);
            }
        }
        else
        {
          active = false;
          agent.Stop();
          changeWaypoint();
          yield return new WaitForSeconds(6f);
          agent.Resume();
          active = true;
        }



        StopCoroutine(patrolRoom());
    }

    void changeWaypoint()
    {
        int newWaypoint = Random.RandomRange(0, waypointCount);
        agent.SetDestination(waypoints[newWaypoint].position);
        currentWaypoint = newWaypoint;
    }


    void OnTriggerEnter(Collider col)
    {
        if (col.gameObject.tag == "Player")
        {
            if (chase)
            {
                outOfSight = false;
                lostValue = 0;
            }
            chase = true;
            patrol = false;
            //  tappedWaitForSecondsOrTap(); 
            //Debug.Log("FOUND YOU");

            if (chase && !AIFOV.enabled)
            {
                StartCoroutine(attack());
            }
        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.gameObject.tag == "Player")
        {
            if (chase)
            {
                outOfSight = true;
            }
           // StartCoroutine(patrolRoom());
        }
    }






    //Advanced Courontines

    private float __gWaitSystem;
    void tappedWaitForSecondsOrTap()
    {
        __gWaitSystem = 0.0f;
    }
    IEnumerator WaitForSecondsOrTap(float seconds)
     {
     __gWaitSystem = seconds;
     while ( __gWaitSystem>0.0 )
         {
         __gWaitSystem -= Time.deltaTime;
            yield return new WaitForEndOfFrame();
         }
     }


}
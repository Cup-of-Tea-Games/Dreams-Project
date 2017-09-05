using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.ThirdPerson;

public class Wanderer : MonoBehaviour
{
    public UnityEngine.AI.NavMeshAgent agent { get; private set; }             // the navmesh agent required for the path finding
    public Transform target;                                    // target to aim for

    private float distance;
    private bool chase = false;
    private bool patrol = true;
    private bool active = true;
    private bool isOnWaypoint = false;
    private int waypointCount = 0;
    private int currentWaypoint = 0;
    private float lostValue;
    private bool lostPlayer = true;

    public Animator animator;
    public WaypointGroup waypoints;
    public float destinationResetTime = 1.0f;
    public Collider hitBox;
    private float originalSpeed;
    private WaypointGroup originalWaypoints;

    public Camera eyes;
    public DamageSystem damageSystem;
    public float health;


    private void Start()
    {
        agent = GetComponentInChildren<UnityEngine.AI.NavMeshAgent>();

        agent = GetComponent<UnityEngine.AI.NavMeshAgent>();
        waypointCount = waypoints.getLength();
        changeWaypoint();
        originalSpeed = agent.speed;
        originalWaypoints = waypoints;
    }

    private void Update()
    {
        AINavigationManager();
        AIHealthManager();
    }

    IEnumerator chaseTarget()
    {
        animator.Play("Walk");
        yield return new WaitForSeconds(0.1f);
        agent.SetDestination(target.position);
        // active = true;
        StopCoroutine(chaseTarget());
      // active = true;
        StopCoroutine(chaseTarget());
    }

    IEnumerator chaseLastLocationTarget()
    {
        if (agent.transform.position == agent.destination)
        {
            yield return new WaitForSeconds(2f);
            patrol = true;
        }
        yield return new WaitForSeconds(0.1f);
        // active = true;
        StopCoroutine(chaseLastLocationTarget());
    }

    IEnumerator attack()
    {
        agent.Stop();
        active = false;
        animator.CrossFade("Attack", 0.3f);
        yield return new WaitForSeconds(0.4f);
        hitBox.enabled = true;
        yield return new WaitForSeconds(0.1f);
        hitBox.enabled = false;
        agent.Resume();
        yield return new WaitForSeconds(1f);
        active = true;
        StopCoroutine(attack());
    }

    IEnumerator patrolArea()
    {

        if (distance < 0.02f)
        {
            active = false;
            agent.Stop();
            int newWaypoint = Random.RandomRange(0, waypointCount);
            agent.SetDestination(waypoints.waypoints[newWaypoint].position);
            yield return new WaitForSeconds(2f);
            agent.Resume();
            animator.CrossFade("Walk", 0.3f);
            yield return new WaitForSeconds(4f);
            active = true;

        }

        //Debug.Log("Patrol Continued");
        StopCoroutine(patrolArea());
    }

    IEnumerator patrolRoom()
    {
        float distance = Vector3.Distance(agent.transform.position, agent.destination);

        if (distance < 1f)
        {
            if (!chase)
            {
                active = false;
                animator.CrossFade("Idle", 1f);
                yield return new WaitForSeconds(3f);
                active = true;
            }
        }
        if (agent.transform.position != agent.destination)
        {
            if (!chase && active)
            {
                animator.CrossFade("Walk", 0f);
            }
        }
        else
        {
            StartCoroutine(resetPath());
        }



        StopCoroutine(patrolRoom());
    }

    IEnumerator resetPath()
    {
        active = false;
        agent.Stop();
        changeWaypoint();
        yield return new WaitForSeconds(3f);
        agent.Resume();
        active = true;
        StopCoroutine(resetPath());
    }

    void changeWaypoint()
    {
        int newWaypoint = Random.RandomRange(0, waypointCount);
        agent.SetDestination(waypoints.waypoints[newWaypoint].position);
        currentWaypoint = newWaypoint;
    }

    void eyesManager()
    {
        RaycastHit hit;
        Vector3 screenPoint = eyes.WorldToViewportPoint(target.position);
        if (screenPoint.z > 0 && screenPoint.x > 0 && screenPoint.x < 1 && screenPoint.y > 0 && screenPoint.y < 1)
        {
            if (Physics.Linecast(eyes.transform.position, target.GetComponentInChildren<Renderer>().bounds.center, out hit))
            {
                if (hit.transform.tag == "Player")
                {
                    chase = true;
                    patrol = false;
                    lostPlayer = false;
                    lostValue = 0;
                    //Debug.Log("FOUND YOU");

                }
                else
                {
                    if (lostValue > 1)
                    {
                        lostPlayer = true;
                        //Debug.Log("LOST YOU");
                    }
                }
            }
        }

        //Look at Player
        if(eyes.GetComponent<Looker>() != null)
        {
            if (chase)
            {
                eyes.GetComponent<Looker>().enabled = true;
            }
            else
            {
                eyes.GetComponent<Looker>().enabled = false;
            }
        }
    }

    void AINavigationManager()
    {

        distance = Vector3.Distance(agent.transform.position, target.transform.position);

        if (distance < 4)
            lostValue = 0;
        else
            lostValue += 0.05f;

        if (lostPlayer && chase)
        {
            chase = false;
            patrol = false;
        }

        if (!patrol)
        {
            agent.speed = originalSpeed * 1f;
        }
        else
        {
            agent.speed = originalSpeed;
        }

        if (chase && !patrol && active)
        {
            // Debug.Log("IS CHASING");
            if(distance > 2)
            StartCoroutine(chaseTarget());
            else
                StartCoroutine(attack());
        }

        else if (patrol && !chase && active)
        {
            StartCoroutine(patrolRoom());
        }

        else if (!patrol && !chase && active)
        {
            StartCoroutine(chaseLastLocationTarget());
        }

        // Debug.Log("Active : " + active);

        //Sees the Player
        eyesManager();

    }

    void AIHealthManager()
    {
        if (damageSystem.isHit())
        {
            health -= damageSystem.damageTaken();
            chase = true;
            patrol = false;
            agent.SetDestination(target.transform.position);
            //Debug.Log("DAMAGE HIT : " + health);
        }
        if (health <= 0)
        {
            die();
        }
    }

    void die()
    {
        if (GetComponent<CharacterController>() != null)
            GetComponent<CharacterController>().enabled = false;
        if (GetComponent<UnityEngine.AI.NavMeshAgent>() != null)
            GetComponent<UnityEngine.AI.NavMeshAgent>().enabled = false;
        if (GetComponent<ThirdPersonCharacter>() != null)
            GetComponent<ThirdPersonCharacter>().enabled = false;

        foreach (Rigidbody rb in GetComponentsInChildren<Rigidbody>())
            if (GetComponentsInChildren<Rigidbody>() != null)
                rb.isKinematic = false;

        animator.enabled = false;
        transform.DetachChildren();
        Destroy(gameObject, 0.2f);
    }

    public void SetTarget(Transform target)
    {
        this.target = target;
    }

}

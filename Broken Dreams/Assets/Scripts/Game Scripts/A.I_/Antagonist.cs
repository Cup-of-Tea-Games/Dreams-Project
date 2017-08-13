using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.ThirdPerson;

public class Antagonist : MonoBehaviour
    {
        public NavMeshAgent agent { get; private set; }             // the navmesh agent required for the path finding
        public ThirdPersonCharacter character { get; private set; } // the character we are controlling
        public Transform target;                                    // target to aim for

        private bool chase = false;
        private bool patrol = true;
        private bool active = true;
        private bool outOfSight = true;
        private bool isOnWaypoint = false;
        private int waypointCount = 0;
        private int currentWaypoint = 0;
        private float lostValue;

        public Animator animator;
        public Transform[] waypoints;
        public float destinationResetTime = 1.0f;
    //    public Collider hitBox;
    //    public Collider AIAttackRange;
        private float originalSpeed;


        private void Start()
        {
            // get the components on the object we need ( should not be null due to require component so no need to check )
            agent = GetComponentInChildren<NavMeshAgent>();
            character = GetComponent<ThirdPersonCharacter>();

            agent.updateRotation = false;
            agent.updatePosition = true;

            agent = GetComponent<NavMeshAgent>();
            waypointCount = waypoints.Length;
            changeWaypoint();
            originalSpeed = agent.speed;
    }


        private void Update()
        {
        float distance = Vector3.Distance(agent.transform.position, target.transform.position);

        if (distance < 15)
            lostValue = 0;
        else
            lostValue += 0.01f;

        if (lostValue > 7 && chase)
        {
            chase = false;
            patrol = true;
        }

        if (chase)
        {
            agent.speed = originalSpeed * 2;
        }
        else
        {
            agent.speed = originalSpeed;
        }

        if (chase && !patrol && active && lostValue < 7)
        {
            // Debug.Log("IS CHASING");
            StartCoroutine(chaseTarget());
        }

        else if (patrol && !chase && active)
        {
            StartCoroutine(patrolArea());
        }

        Debug.Log("Active : " + active);

        //Sets the A.I.
        if (agent.remainingDistance > agent.stoppingDistance)
                character.Move(agent.desiredVelocity, false, false);
            else
                character.Move(Vector3.zero, false, false);
        }

    IEnumerator chaseTarget()
    {
        yield return new WaitForSeconds(0.1f);
        agent.SetDestination(target.position);
        // active = true;
        StopCoroutine(chaseTarget());
    }

    IEnumerator attack()
    {
        // agent.Stop();
        active = false;
        animator.CrossFade("Attack", 0.3f);
        yield return new WaitForSeconds(0.1f);
        //hitBox.enabled = true;
        yield return new WaitForSeconds(0.1f);
        //hitBox.enabled = false;
        // agent.Resume();
        // yield return new WaitForSeconds(1f);
        active = true;
        StopCoroutine(attack());
    }

    IEnumerator patrolArea()
    {

        float distance = Vector3.Distance(agent.transform.position, agent.destination);

        if (distance < 0.02f)
        {
            active = false;
            agent.Stop();
            int newWaypoint = Random.RandomRange(0, waypointCount);
            agent.SetDestination(waypoints[newWaypoint].position);
            yield return new WaitForSeconds(2f);
            agent.Resume();
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
                //animator.CrossFade("Idle", 1f);
                yield return new WaitForSeconds(2f);
                active = true;
            }
        }
        if (agent.transform.position != agent.destination)
        {
            if (!chase && active)
            {
                agent.Resume();
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
        agent.SetDestination(waypoints[newWaypoint].position);
        currentWaypoint = newWaypoint;
    }

    public void SetTarget(Transform target)
        {
            this.target = target;
        }

    }

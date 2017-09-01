using UnityEngine;
using System.Collections;
using UnityStandardAssets.Characters.ThirdPerson;

public class Antagonist : MonoBehaviour
    {
        public NavMeshAgent agent { get; private set; }             // the navmesh agent required for the path finding
        public ThirdPersonCharacter character { get; private set; } // the character we are controlling
        public Transform target;                                    // target to aim for

        private float distance;
        private bool chase = false;
        private bool patrol = true;
        private bool active = true;
        private bool outOfSight = true;
        private bool isOnWaypoint = false;
        private int waypointCount = 0;
        private int currentWaypoint = 0;
        private float lostValue;
        private bool lostPlayer = true;

        private bool isInRoom = false;
        WaypointGroup roomWaypoints;
        private int roomWaypointDestinationCount = 0;

        public Animator animator;
        public WaypointGroup waypoints;
        public float destinationResetTime = 1.0f;
    //    public Collider hitBox;
    //    public Collider AIAttackRange;
        private float originalSpeed;
        private WaypointGroup originalWaypoints;
        public Collider hitBox;

        public Camera eyes;
        public DamageSystem damageSystem;
        public float health;


        private void Start()
        {
            // get the components on the object we need ( should not be null due to require component so no need to check )
            agent = GetComponentInChildren<NavMeshAgent>();
            character = GetComponent<ThirdPersonCharacter>();

            agent.updateRotation = false;
            agent.updatePosition = true;

            agent = GetComponent<NavMeshAgent>();
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
        agent.speed = originalSpeed * 1.5f;


        yield return new WaitForSeconds(0.1f);
        if (distance > 2)
            agent.SetDestination(target.position);
        else
            agent.SetDestination(agent.transform.position);
        // active = true;
        StopCoroutine(chaseTarget());
    }

        IEnumerator chaseLastLocationTarget()
    {

        agent.speed = originalSpeed * 1.5f;


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
        yield return new WaitForSeconds(0.1f);
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

        agent.speed = originalSpeed;

        float distance = Vector3.Distance(agent.transform.position, agent.destination);

        if (distance < 0.02f)
        {
            active = false;
            agent.Stop();
            int newWaypoint = Random.RandomRange(0, waypointCount);
            agent.SetDestination(waypoints.waypoints[newWaypoint].position);
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
        agent.speed = originalSpeed;

        float distance = Vector3.Distance(agent.transform.position, agent.destination);

        if (distance < 0.02f)
        {
            active = false;
            agent.Stop();
            agent.SetDestination(roomWaypoints.waypoints[roomWaypointDestinationCount].position);
            yield return new WaitForSeconds(2f);
            agent.Resume();
            yield return new WaitForSeconds(4f);
            active = true;
            roomWaypointDestinationCount++;
        }

        if(roomWaypointDestinationCount >= roomWaypoints.waypoints.Length)
        {
            roomWaypointDestinationCount = 0;
            isInRoom = false;
            patrol = true;
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
        if (eyes.GetComponent<Looker>() != null)
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
        Debug.Log(roomWaypointDestinationCount);
        if (distance < 2)
            lostValue = 0;
        else
            lostValue += 0.04f;

        if (lostPlayer && chase)
        {
            chase = false;
            patrol = false;
        }

        if (chase && !patrol && active)
        {
            // Debug.Log("IS CHASING");
            if (distance > 3f)
                StartCoroutine(chaseTarget());
            else
                StartCoroutine(attack());
        }

        else if (patrol && !chase && active)
        {
            StartCoroutine(patrolArea());
        }

        else if (!patrol && !chase && active && !isInRoom)
        {
            StartCoroutine(chaseLastLocationTarget());
        }

        else if (!patrol && !chase && active && isInRoom)
        {
            StartCoroutine(patrolRoom());
        }

        // Debug.Log("Active : " + active);

        //Sets the A.I.
        if (agent.remainingDistance > agent.stoppingDistance)
            character.Move(agent.desiredVelocity, false, false);
        else
            character.Move(Vector3.zero, false, false);

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
        if (GetComponent<NavMeshAgent>() != null)
            GetComponent<NavMeshAgent>().enabled = false;
        if (GetComponent<ThirdPersonCharacter>() != null)
            GetComponent<ThirdPersonCharacter>().enabled = false;

        foreach (Rigidbody rb in GetComponentsInChildren<Rigidbody>())
            if(GetComponentsInChildren<Rigidbody>() != null)
            rb.isKinematic = false;

        animator.enabled = false;
        transform.DetachChildren();
        Destroy(gameObject,0.2f);
    }

        public void SetTarget(Transform target)
        {
            this.target = target;
        }

        private void OnTriggerEnter(Collider other)
        {
        if (other.GetComponent<Room>() != null)
        {
            isInRoom = true;
            roomWaypoints = other.GetComponent<Room>().waypoints;
        }
        }

        private void OnTriggerExit(Collider other)
    {
        if (other.GetComponent<Room>() != null)
        {
            isInRoom = false;
            roomWaypoints = null;
        }
    }

}

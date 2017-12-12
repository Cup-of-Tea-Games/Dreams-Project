using System;
using UnityEngine;
using UnityStandardAssets.CrossPlatformInput;
using UnityStandardAssets.Utility;
using Random = UnityEngine.Random;
using System.Collections;

namespace UnityStandardAssets.Characters.FirstPerson
{
    [RequireComponent(typeof(CharacterController))]
    [RequireComponent(typeof(AudioSource))]
    public class FirstPersonController : MonoBehaviour
    {
        [SerializeField] private bool m_IsWalking;
        [SerializeField] private float m_WalkSpeed;
        [SerializeField] private float m_RunSpeed;
        [SerializeField] [Range(0f, 1f)] private float m_RunstepLenghten;
        [SerializeField] private float m_JumpSpeed;
        [SerializeField] private float m_StickToGroundForce;
        [SerializeField] private float m_GravityMultiplier;
        private MouseLook m_MouseLook;
        [SerializeField] private bool m_UseFovKick;
        [SerializeField] private FOVKick m_FovKick = new FOVKick();
        [SerializeField] private bool m_UseHeadBob;
        [SerializeField] private CurveControlledBob m_HeadBob = new CurveControlledBob();
        [SerializeField] private LerpControlledBob m_JumpBob = new LerpControlledBob();
        [SerializeField] private float m_StepInterval;
        [SerializeField] private AudioClip[] m_FootstepSounds;    // an array of footstep sounds that will be randomly selected from.
        [SerializeField] private AudioClip m_JumpSound;           // the sound played when character leaves the ground.
        [SerializeField] private AudioClip m_LandSound;           // the sound played when character touches back on ground.

        private Camera m_Camera;
        private bool m_Jump;
        private float m_YRotation;
        private Vector2 m_Input;
        private Vector3 m_MoveDir = Vector3.zero;
        private CharacterController m_CharacterController;
        private CollisionFlags m_CollisionFlags;
        private bool m_PreviouslyGrounded;
        private Vector3 m_OriginalCameraPosition;
        private float m_StepCycle;
        private float m_NextStep;
        private bool m_Jumping;
        private AudioSource m_AudioSource;

        //Crouching
        public static bool isCrouching;
        public static bool inCrouchZone;
        private bool delayCrouch = true;
        //Ladder Climbing
        public static bool isClimbing;
        public static Ladder ladder;
        private bool climbActivation = false;
        public FollowTarget cameraAxis;

        //Ladder
        public float ladderClimbSpeed = 0.05f;
        public float ladderDampening = 0.05f;

        //Misc
        public static float airTime = 0;
        public static bool isGrounded;
        public static bool isSwimming;
        public static bool isPeeking;
        bool canSwim = true;
        bool sitActivator = true;
        public static float currentSpeed;

        //Vaulting
        public Vaulter vaulter;
        bool vaultUpActivator = true;
        bool vaultForwardActivator = true;

        public static bool mouseLookResetter = false;

        //Apartment Exclusives
        public bool isInHub = false;

        public static Transform reference;

        //Camera Axis Holder
        public Transform cameraHolder;

        //ANIMATION
        public Animator m_Animator;
        Rigidbody m_Rigidbody;
        float m_GroundCheckDistance = 0.1f;
        bool m_IsGrounded;
        float m_OrigGroundCheckDistance;
        float m_ForwardAmount;
        float m_SideAmount;
        Vector3 m_GroundNormal;
        float m_AnimSpeedMultiplier = 1f;

        void Awake()
        {
            m_MouseLook = GetComponent<MouseLook>();
            AudioListener.volume = 1;
            Time.timeScale = 1;
            reference = this.transform;
        }

        // Use this for initialization
        private void Start()
        {
            m_CharacterController = GetComponent<CharacterController>();
            m_Camera = Camera.main;
            m_OriginalCameraPosition = m_Camera.transform.localPosition;
            m_FovKick.Setup(m_Camera);
            m_HeadBob.Setup(m_Camera, m_StepInterval);
            m_StepCycle = 0f;
            m_NextStep = m_StepCycle / 2f;
            m_Jumping = false;
            m_AudioSource = GetComponent<AudioSource>();
            m_MouseLook.Init(transform, cameraHolder);

            m_OrigGroundCheckDistance = m_GroundCheckDistance;
            m_Rigidbody = GetComponent<Rigidbody>();
        }

        // Update is called once per frame
        private void Update()
        {
          //  Debug.Log("Crouching " + isCrouching);
            //Animation Handler
            performAnimation();

            //Grounded Checker
            isGrounded = m_CharacterController.isGrounded;

            if (!InventoryMenu.inventroyIsUp && !PageViewer.PageViewerIsUp)
            {
                if (m_CharacterController.isGrounded || Input.GetKey(KeyCode.Space))
                {
                    airTime = 0;
                }
                else
                {
                    airTime += Time.deltaTime;
                }

                RotateView();
                // the jump state needs to read here to make sure it is not missed
                if (!m_Jump)
                {
                    m_Jump = CrossPlatformInputManager.GetButtonDown("Jump");
                }

                if (!m_PreviouslyGrounded && m_CharacterController.isGrounded)
                {
                    if(!SitDown.isSatDown)
                    StartCoroutine(m_JumpBob.DoBobCycle());
                    PlayLandingSound();
                    m_MoveDir.y = 0f;
                    m_Jumping = false;
                }
                if (!m_CharacterController.isGrounded && !m_Jumping && m_PreviouslyGrounded)
                {
                    m_MoveDir.y = 0f;
                }

                m_PreviouslyGrounded = m_CharacterController.isGrounded;

                //Handle Rotation
                if (Input.GetKey(KeyCode.R) && Raycast_Pickup.isGrabbing)
                {
                    m_MouseLook.XSensitivity = 0;
                    m_MouseLook.YSensitivity = 0;
                }
                else
                {
                    if (m_MouseLook != null)
                    {
                        if (!isClimbing)
                            m_MouseLook.XSensitivity = 3;
                        m_MouseLook.YSensitivity = 3;
                    }
                }

                // Swimming & Water Walking
                if (WaterInteraction.isOnWater)
                {
                    m_WalkSpeed = 3;
                    m_RunSpeed = 5;
                    m_JumpSpeed = 6;

                    if (WaterInteraction.isOnDeepWater)
                    {
                        isSwimming = true;

                        if (WaterInteraction.isUnderWater && WaterInteraction.isSemiUnderWater)
                        {
                            GetComponent<Rigidbody>().velocity = new Vector3(GetComponent<Rigidbody>().velocity.z / 6, GetComponent<Rigidbody>().velocity.y / 6, GetComponent<Rigidbody>().velocity.z / 6);


                            m_Jump = false;
                            m_JumpSpeed = 0;
                            m_GravityMultiplier = 0.2f;
                            if(canSwim)
                            if (Input.GetKey(KeyCode.Space))
                                m_MoveDir.y = 1.8f;
                            else if (Input.GetKey(KeyCode.LeftControl))
                                m_MoveDir.y = -1.8f;
                        }
                        else if(!WaterInteraction.isUnderWater && WaterInteraction.isSemiUnderWater)
                        {
                            m_Jump = false;
                            m_JumpSpeed = 0;
                            if (canSwim)
                                if (Input.GetKey(KeyCode.Space))
                                {
                                    if (transform.position.y + 3 < WaterInteraction.waterInstance.transform.position.y)
                                        m_MoveDir.y = 1f;
                                    else
                                    {
                                        m_MoveDir.y = 0;
                                        m_GravityMultiplier = 0f;
                                    }
                                     //   transform.position = new Vector3(transform.position.x, WaterInteraction.waterInstance.transform.position.y + 3, transform.position.z);
                                }
                                else if (Input.GetKey(KeyCode.LeftControl))
                                    m_MoveDir.y = -1f;
                            else
                                    m_GravityMultiplier = 0.03f;

                        }
                    }
                    else
                        if(m_CharacterController.isGrounded)
                        m_GravityMultiplier = 4;
                        m_JumpSpeed = 6;
                }
                else
                {
                    m_JumpSpeed = 8;
                        m_GravityMultiplier = 4;
                    isSwimming = false;
                }


                //Crouching
                if (!WaterInteraction.isOnDeepWater && !SitDown.isSatDown)
                CrouchAbility();

                if (Input.GetKey(KeyCode.LeftShift))
                    isCrouching = false;

                //Climb Ladders
                LadderClimber();

                //Peeking
                //  Peeker();

                VaultMechanic();
                if(Raycast_Pickup.chairInstance != null && Raycast_Pickup.chairInstance.GetComponent<SitDown>() != null)
                if (Raycast_Pickup.chairInstance.GetComponent<SitDown>().canSitDown)
                {
                    ChairSitter();
                }
                if(SitDown.isSatDown)
                    m_UseHeadBob = false;

                if (mouseLookResetter)
                {
                    mouseLookResetter = false;
                    Destroy(m_MouseLook);
                    m_MouseLook = gameObject.AddComponent<MouseLook>();
                    m_MouseLook.Init(transform, cameraHolder);
                    Debug.Log("Resetted Mouse Look");
                }

                if (GetComponent<Rigidbody>().detectCollisions == true)
                    m_UseHeadBob = true;


            }// SUPER IF
        }

        private void CrouchAbility()
        {
            //Crouching Beneath Objects
            if (GetComponent<Collider>().gameObject.tag == "CrouchArea")
                inCrouchZone = true;
            else
                inCrouchZone = false;

            //Crouching Command
            if (Input.GetKey(KeyCode.LeftControl))
            {
                if (delayCrouch == true)
                {
                    delayCrouch = false;
                    isCrouching = !isCrouching;
                    StartCoroutine(delay(1f));
                }

            }
            else
                if (inCrouchZone)
                delayCrouch = false;
            else
                delayCrouch = true;


            //Crouching Technical
            if (isCrouching)
            {
                cameraAxis.offset.y = -0.15f;
                //Adjust Camera Center
                if (GetComponent<CharacterController>().center.y < -1f)
                    GetComponent<CharacterController>().center += new Vector3(0, 0.1f, 0);
                 else if (GetComponent<CharacterController>().center.y > -1F)
                    GetComponent<CharacterController>().center = new Vector3(0, -1.0f, 0);
                //Adjust Height
                GetComponent<CharacterController>().height = 1.5f;
                m_WalkSpeed = 3;
            }
            else
            {
                cameraAxis.offset.y = 0;
                //Adjust Camera Center
                if (GetComponent<CharacterController>().center.y > 0)
                    GetComponent<CharacterController>().center -= new Vector3(0, 0.1f, 0);
                else if (GetComponent<CharacterController>().center.y < 0)
                    GetComponent<CharacterController>().center = new Vector3(0, 0f, 0);
                //Adjust Height
                if (GetComponent<CharacterController>().height < 3.5f)
                    GetComponent<CharacterController>().height += 0.2f;

                if (GetComponent<CharacterController>().height > 3.5f)
                    GetComponent<CharacterController>().height = 3.5f;

                if (!WaterInteraction.isOnWater)
                {
                    m_WalkSpeed = 4;
                    m_RunSpeed = 6;

                   if(isInHub)
                    {
                        m_WalkSpeed = 3;
                        m_RunSpeed = 5;
                    }
                }
            }
        }

        public IEnumerator delay(float time)
        {
            yield return new WaitForSeconds(time);
            delayCrouch = true;
            StopCoroutine(delay(time));
        }

        private void PlayLandingSound()
        {
            m_AudioSource.clip = m_LandSound;
//            m_AudioSource.Play();
            m_NextStep = m_StepCycle + .5f;
        }

        private void FixedUpdate()
        {
            if(!InventoryMenu.inventroyIsUp && !PageViewer.PageViewerIsUp && !Computer.isOnPC)
            { 
            float speed;

            GetInput(out speed);
            // always move along the camera forward as it is the direction that it being aimed at
            Vector3 desiredMove = transform.forward * m_Input.y + transform.right * m_Input.x;

            // get a normal for the surface that is being touched to move along it
            RaycastHit hitInfo;
            Physics.SphereCast(transform.position, m_CharacterController.radius, Vector3.down, out hitInfo,
                               m_CharacterController.height / 2f);
            desiredMove = Vector3.ProjectOnPlane(desiredMove, hitInfo.normal).normalized;

                if (!Vaulter.isVaulting)
                {
                    if (m_CharacterController.isGrounded)
                    {
                        if (m_Input.magnitude > 0)
                        {
                            m_MoveDir = Vector3.Lerp(m_MoveDir, desiredMove * speed, Time.deltaTime * 6);
                            m_UseHeadBob = true;
                        }
                        else
                        {
                            m_MoveDir = Vector3.Lerp(m_MoveDir, desiredMove * speed, Time.deltaTime * 12);
                            m_UseHeadBob = false;
                        }
                    }
                    else
                    {
                        m_MoveDir = Vector3.Lerp(m_MoveDir, desiredMove * speed, 0);
                    }
                }
                else
                {
                    m_MoveDir.x = 0;
                    m_MoveDir.z = 0;
                }


            if (!isInHub && (m_CharacterController.isGrounded || isClimbing) && !(WaterInteraction.isSemiUnderWater && WaterInteraction.isOnDeepWater) &&!Vaulter.isVaulting)
            {
                m_MoveDir.y = -m_StickToGroundForce;

                if (m_Jump)
                {
                    m_MoveDir.y = m_JumpSpeed;
                    PlayJumpSound();
                    m_Jump = false;
                    m_Jumping = true;
                    isClimbing = false;
                }
            }
            else
            {
                if (!isClimbing && !Vaulter.isVaulting)
                    m_MoveDir += Physics.gravity * m_GravityMultiplier * Time.fixedDeltaTime;
            }
            if (!isClimbing && !SitDown.isSatDown)
                m_CollisionFlags = m_CharacterController.Move(m_MoveDir * Time.fixedDeltaTime);

            ProgressStepCycle(speed);
            UpdateCameraPosition(speed);
        }
        }

        private void PlayJumpSound()
        {
            m_AudioSource.clip = m_JumpSound;
            m_AudioSource.Play();
        }

        private void ProgressStepCycle(float speed)
        {
            if (m_CharacterController.velocity.sqrMagnitude > 0 && (m_Input.x != 0 || m_Input.y != 0))
            {
                m_StepCycle += (m_CharacterController.velocity.magnitude + (speed*(m_IsWalking ? 1f : m_RunstepLenghten)))*
                             Time.fixedDeltaTime;
            }

            if (!(m_StepCycle > m_NextStep))
            {
                return;
            }

            m_NextStep = m_StepCycle + m_StepInterval;

            PlayFootStepAudio();
        }

        private void PlayFootStepAudio()
        {
            if (!m_CharacterController.isGrounded)
            {
                return;
            }
            // pick & play a random footstep sound from the array,
            // excluding sound at index 0
            int n = Random.Range(1, m_FootstepSounds.Length);
            m_AudioSource.clip = m_FootstepSounds[n];
            m_AudioSource.PlayOneShot(m_AudioSource.clip);
            // move picked sound to index 0 so it's not picked next time
            m_FootstepSounds[n] = m_FootstepSounds[0];
            m_FootstepSounds[0] = m_AudioSource.clip;
        }

        private void UpdateCameraPosition(float speed)
        {
            Vector3 newCameraPosition;
            if (!m_UseHeadBob)
            {
                return;
            }
            if (m_CharacterController.velocity.magnitude > 0 && m_CharacterController.isGrounded && !isClimbing)
            {
                m_Camera.transform.localPosition =
                    m_HeadBob.DoHeadBob(m_CharacterController.velocity.magnitude +
                                      (speed*(m_IsWalking ? 1f : m_RunstepLenghten)));
                newCameraPosition = m_Camera.transform.localPosition;
                newCameraPosition.y = m_Camera.transform.localPosition.y - m_JumpBob.Offset();
            }
            else
            {
                newCameraPosition = m_Camera.transform.localPosition;
                newCameraPosition.y = m_OriginalCameraPosition.y - m_JumpBob.Offset();
            }
            m_Camera.transform.localPosition = newCameraPosition;
        }

        private void GetInput(out float speed)
        {
            // Read input
            float horizontal = CrossPlatformInputManager.GetAxis("Horizontal");
            float vertical = CrossPlatformInputManager.GetAxis("Vertical");

            bool waswalking = m_IsWalking;

#if !MOBILE_INPUT
            // On standalone builds, walk/run speed is modified by a key press.
            // keep track of whether or not the character is walking or running
            m_IsWalking = !Input.GetKey(KeyCode.LeftShift);
#endif
            // set the desired speed to be walking or running
            speed = m_IsWalking ? m_WalkSpeed : m_RunSpeed;
            currentSpeed = m_IsWalking ? m_WalkSpeed : m_RunSpeed;
            m_Input = new Vector2(horizontal, vertical);

            // normalize input if it exceeds 1 in combined length:
            if (m_Input.sqrMagnitude > 1)
            {
                m_Input.Normalize();
            }

            // handle speed change to give an fov kick
            // only if the player is going to a run, is running and the fovkick is to be used
            if (m_IsWalking != waswalking && m_UseFovKick && m_CharacterController.velocity.sqrMagnitude > 0)
            {
                StopAllCoroutines();
                StartCoroutine(!m_IsWalking ? m_FovKick.FOVKickUp() : m_FovKick.FOVKickDown());
            }
        }

        private void RotateView()
        {
            if(m_MouseLook != null)
            m_MouseLook.LookRotation (transform, cameraHolder);
        }

        private void OnControllerColliderHit(ControllerColliderHit hit)
        {
            Rigidbody body = hit.collider.attachedRigidbody;
            //dont move the rigidbody if the character is on top of it
            if (m_CollisionFlags == CollisionFlags.Below)
            {
                return;
            }

            if (body == null || body.isKinematic)
            {
                return;
            }
            body.AddForceAtPosition(m_CharacterController.velocity*0.1f, hit.point, ForceMode.Impulse);
        }

        private void LadderClimber()
        {
            if (isClimbing)
            {
                Destroy(m_MouseLook);
                transform.position = Vector3.Lerp(transform.position, ladder.ClimbPosition.position, ladderDampening * Time.deltaTime);
               // transform.position = ladder.ClimbPosition.position;
                transform.rotation = Quaternion.Lerp(transform.rotation, ladder.ClimbPosition.rotation, 4 *Time.deltaTime);
                if (Input.GetKey(KeyCode.W))
                ladder.ClimbPosition.transform.position += new Vector3(0,ladderClimbSpeed,0);
                else if (Input.GetKey(KeyCode.S))
                ladder.ClimbPosition.transform.position -= new Vector3(0, ladderClimbSpeed, 0);
                StartCoroutine(waitTime(1f));
                m_MouseLook = gameObject.AddComponent<MouseLook>();
                m_MouseLook.Init(transform, cameraHolder);
                climbActivation = true;
                Debug.Log("Climbing Ladder");
            }
            else
            {
                if (climbActivation)
                {
                    climbActivation = false;
                    Debug.Log("Destroyed MouseLook");                  
                }
            }
        }

        private void VaultMechanic()
        {
            if (Vaulter.isVaulting)
            {
                m_Jump = false;
                StartCoroutine(Vault());
                // transform.position = ladder.ClimbPosition.position;
            }

        }

        private IEnumerator Vault()
        {
            if(vaultUpActivator && Vaulter.isVaulting)
            transform.position = Vector3.Lerp(transform.position, vaulter.Vertical_Destination.transform.position, ladderDampening * Time.deltaTime);
            yield return new WaitForSeconds(0.25f);
            vaultUpActivator = false;

            if (vaultForwardActivator && Vaulter.isVaulting)
            transform.position = Vector3.Lerp(transform.position, vaulter.Horizontal_Destination.transform.position, ladderDampening * Time.deltaTime);
            yield return new WaitForSeconds(0.2f);
            vaultForwardActivator = false;
            Vaulter.isVaulting = false;
            vaulter.recoverHook();

            yield return new WaitForSeconds(0.2f);
            vaultForwardActivator = true;
            vaultUpActivator = true;
            //StopCoroutine(Vault());
        }

        private void ChairSitter()
        {

            if (SitDown.sitDown)
            {
                m_WalkSpeed = 0;
                m_RunSpeed = 0;
                m_MoveDir.y = 0;
            }
            if (SitDown.isSatDown)
            {
                sitActivator = true;
                m_MoveDir.y = 0;
            }


        }

        /*
        private void Peeker()
        {
            if (Input.GetKeyDown(KeyCode.Q))
            {
                m_MouseLook.LeanLeft();
            }

            else if (Input.GetKeyDown(KeyCode.E))
            {
                m_MouseLook.LeanRight();
            }

            else if (!Input.GetKey(KeyCode.Q) && !Input.GetKey(KeyCode.E))
            {
                m_MouseLook.LeanBack();
            }

        }
        */


        public IEnumerator waitTime(float x)
        {
            yield return new WaitForSeconds(x);
          //Debug.Log("Eh");
            StopCoroutine(waitTime(x));
        }


        public IEnumerator waterDelay()
        {
            yield return new WaitForSeconds(1.8f);
            canSwim = true;
           // StopCoroutine(waterDelay());
        }

        public IEnumerator mouseLookReset()
        {
            if (sitActivator)
            {
                Destroy(m_MouseLook);
                yield return new WaitForSeconds(0.1f);
                m_MouseLook = gameObject.AddComponent<MouseLook>();
                m_MouseLook.Init(transform, cameraHolder);
                sitActivator = false;
                StopCoroutine(mouseLookReset());
            }
        }

        //ANIMATION RELATED

        void HandleAirborneMovement()
        {
            m_GroundCheckDistance = m_Rigidbody.velocity.y < 0 ? m_OrigGroundCheckDistance : 0.01f;
        }

        void CheckGroundStatus()
        {
            RaycastHit hitInfo;
#if UNITY_EDITOR
            // helper to visualise the ground check ray in the scene view
            Debug.DrawLine(transform.position + (Vector3.up * 0.1f), transform.position + (Vector3.up * 0.1f) + (Vector3.down * m_GroundCheckDistance));
#endif
            // 0.1f is a small offset to start the ray from inside the character
            // it is also good to note that the transform position in the sample assets is at the base of the character
            if (Physics.Raycast(transform.position + (Vector3.up * 0.1f), Vector3.down, out hitInfo, m_GroundCheckDistance))
            {
                m_GroundNormal = hitInfo.normal;
                m_IsGrounded = true;
                m_Animator.applyRootMotion = true;
            }
            else
            {
                m_IsGrounded = false;
                m_GroundNormal = Vector3.up;
                m_Animator.applyRootMotion = false;
            }
        }

        void monitorMovement()
        {
         //   move = transform.InverseTransformDirection(move);
            CheckGroundStatus();
            m_ForwardAmount = transform.InverseTransformDirection(gameObject.transform.position).z;
        }

        void UpdateAnimator()
		{
            Vector3 localVelocity = transform.InverseTransformDirection(m_CharacterController.velocity);
            float forwardSpeed = localVelocity.z;
            float sideSpeed = localVelocity.x;
          //  Debug.Log(localVelocity + ":" + GetComponent<Rigidbody>().velocity);

            // update the animator parameters
            m_Animator.SetFloat("Forward",forwardSpeed, 0.1f, Time.deltaTime);
			m_Animator.SetFloat("Side",sideSpeed, 0.1f, Time.deltaTime);
			m_Animator.SetBool("Crouch", isCrouching);
			m_Animator.SetBool("OnGround", isGrounded);
			if (!m_IsGrounded)
			{
				m_Animator.SetFloat("Jump", m_Rigidbody.velocity.y);
			}

			// the anim speed multiplier allows the overall speed of walking/running to be tweaked in the inspector,
			// which affects the movement speed because of the root motion.
			if (m_IsGrounded && transform.GetComponent<Rigidbody>().velocity.magnitude > 0)
			{
				m_Animator.speed = m_AnimSpeedMultiplier;
			}
			else
			{
				// don't use that while airborne
				m_Animator.speed = 1;
			}
		}

        void performAnimation()
        {
            UpdateAnimator();
            monitorMovement();
            CheckGroundStatus();
            HandleAirborneMovement();
        }
    }
}

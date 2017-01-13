using System;
using UnityEngine;
using UnityStandardAssets.CrossPlatformInput;

namespace UnityStandardAssets.Characters.FirstPerson
{
    public class MouseLook : MonoBehaviour
    {
        public float XSensitivity = 3f;
        public float YSensitivity = 3f;
        public bool clampVerticalRotation = true;
        public float MinimumX = -90F;
        public float MaximumX = 90F;
        public bool smooth;
        public float smoothTime = 14f;
        private bool freezeX;
        private bool freezeY;


        private Quaternion m_CharacterTargetRot;
        private Quaternion m_CameraTargetRot;

        float yRot;
        float xRot;
        float zRot = 0f;
        bool isInMiddle = true;
        bool isLeaning = false;
        //Misc
        bool deleteActivator = false;

        public void Init(Transform character, Transform camera)
        {
            m_CharacterTargetRot = character.localRotation;
            m_CameraTargetRot = camera.localRotation;
        }


        public void LookRotation(Transform character, Transform camera)
        {

            yRot = CrossPlatformInputManager.GetAxis("Mouse X") * XSensitivity;
            xRot = CrossPlatformInputManager.GetAxis("Mouse Y") * YSensitivity;
            m_CharacterTargetRot.z = Mathf.Clamp(m_CharacterTargetRot.z, -0.25f, 0.25f);
            m_CharacterTargetRot *= Quaternion.Euler(0f, yRot, m_CameraTargetRot.z);
            m_CameraTargetRot *= Quaternion.Euler(-xRot, 0f, m_CameraTargetRot.z);

            if (clampVerticalRotation)
                m_CameraTargetRot = ClampRotationAroundXAxis(m_CameraTargetRot);

            if (smooth)
            {
                character.localRotation = Quaternion.Slerp(character.localRotation, m_CharacterTargetRot,
                    smoothTime * Time.deltaTime);
                camera.localRotation = Quaternion.Slerp(camera.localRotation, m_CameraTargetRot,
                    smoothTime * Time.deltaTime);
            }
            else
            {
                if (!Peeking.isPeeking)
                {
                    camera.localRotation = m_CameraTargetRot;
                    character.localRotation = m_CharacterTargetRot;
                }
                else
                    m_CharacterTargetRot = character.localRotation;
                    m_CameraTargetRot = camera.localRotation;

            }

         /*   if (m_CharacterTargetRot.z >= 0.25f)
                zRot = 0;
            else if (m_CharacterTargetRot.z <= -0.25f)
                zRot = 0;

            if (m_CharacterTargetRot.z >= 0.005f || m_CharacterTargetRot.z <= -0.0051f)
            {
                yRot = 0;
                isInMiddle = false;
                deleteActivator = true;
            }
            else
                isInMiddle = true;

           if  (m_CharacterTargetRot.z <= 0.25f || m_CharacterTargetRot.z >= -0.25f)

            Debug.Log(m_CharacterTargetRot.z); */

        }


        Quaternion ClampRotationAroundXAxis(Quaternion q)
        {
            q.x /= q.w;
            q.y /= q.w;
            q.z /= q.w;
            q.w = 1.0f;

            float angleX = 2.0f * Mathf.Rad2Deg * Mathf.Atan(q.x);

            angleX = Mathf.Clamp(angleX, MinimumX, MaximumX);

            q.x = Mathf.Tan(0.5f * Mathf.Deg2Rad * angleX);

            return q;
        }




        //Peeking Functions 

 /*     public void LeanLeft()
        {
            if (m_CharacterTargetRot.z <= 0.25f)
                zRot = 1f;
            isLeaning = true;
        }

        public void LeanRight()
        {
            if (m_CharacterTargetRot.z >= -0.25f)
                zRot = -1f;
            isLeaning = true;
        }

        public void LeanBack()
        {
            isLeaning = false;

            if (isInMiddle && !isLeaning)
            {
                zRot = 0;
            }

            else if (m_CharacterTargetRot.z > 0 && !isInMiddle && !isLeaning)
            {
                zRot = -1.1f;
            }
            else if (m_CharacterTargetRot.z < 0 && !isInMiddle && !isLeaning)
            {
                zRot = 1.1f;
            }


            //  m_CharacterTargetRot *= Quaternion.Euler(0f, yRot, 0);

        }

        public bool isCentered()
        {
            return (isInMiddle && deleteActivator);
        }
        */
    }
}

using UnityEngine;
using System.Collections;

namespace TeaClasses.TimeMan
{

    public struct TimeMan
    {
        class DelayManager : MonoBehaviour
        {

            private IEnumerator yieldSeconds(float x)
            {
                Debug.Log("Waiting :" + x + " Seconds");
                yield return new WaitForSeconds(x);
                StopCoroutine(yieldSeconds((x)));
            }

            public void WaitSeconds(float f)
            {
                StartCoroutine(yieldSeconds(f));
            }

            private IEnumerator yieldWhile(System.Func<bool> x)
            {
                Debug.Log("Waiting :" + x + " Seconds");
                yield return new WaitWhile(x);
                StopCoroutine(yieldWhile((x)));
            }

            public void WaitWhile(System.Func<bool> x)
            {
                StartCoroutine(yieldWhile(x));
            }

        }

        public void WaitSeconds(float f)
        {
            DelayManager dManager = new DelayManager();

            dManager.WaitSeconds(f);
        }
    }
}

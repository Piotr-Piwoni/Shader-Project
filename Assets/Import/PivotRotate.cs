using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PivotRotate : MonoBehaviour
{
    public float rotate = 5f;

    // Update is called once per frame
    void Update()
    {
        var pivotRotation = transform.rotation;
        transform.Rotate(0f,rotate * Time.deltaTime,0f, Space.Self);
    }
}

using UnityEngine;

public class DemoDynamicMatCapCameraController : MonoBehaviour
{
    private void Update ()
    {
        transform.Rotate(new Vector3(0, Input.GetAxis("Horizontal"), 0) * 100 * Time.deltaTime);
	}
}

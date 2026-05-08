using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private float smoothTime = 0.2f;
    private Vector3 velocity = Vector3.zero;

    void LateUpdate()
    {
        transform.position = Vector3.SmoothDamp(
            transform.position,
            new Vector3(target.position.x, target.position.y, transform.position.z),
            ref velocity,
            smoothTime
        );
    }
}

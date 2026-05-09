using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class ToolController : MonoBehaviour
{
    [SerializeField] private Tool tool;
    [SerializeField] private float linearMax;
    [SerializeField] private float angularMax;
    [SerializeField] private float linearScale;
    [SerializeField] private float angularScale;

    private Coroutine toolCoroutine;

    void Update()
    {
        Vector2 mouseDelta = Mouse.current.delta.ReadValue();
        MoveToolBy(new Vector2(mouseDelta.x * linearScale, 0), mouseDelta.y * angularScale, Time.deltaTime);
    }

    private void MoveToolBy(Vector2 displacement, float angle, float duration)
    {
        Vector2 startPosition = new Vector2(transform.position.x, transform.position.y);
        Vector2 targetPosition = startPosition + displacement;
        float startRotation = transform.eulerAngles.z;
        float targetRotation = startRotation + angle;
        MoveToolTo(targetPosition, targetRotation, duration);
    }

    private void MoveToolTo(Vector2 targetPosition, float targetRotation, float duration)
    {
        if (toolCoroutine != null)
            return;
        toolCoroutine = StartCoroutine(MoveToolCoroutine(targetPosition, targetRotation, duration));
    }

    private IEnumerator MoveToolCoroutine(Vector2 targetPosition, float targetRotation, float duration)
    {
        float elapsed = 0f;
        Vector2 startPosition = new Vector2(transform.position.x, transform.position.y);
        float startRotation = transform.eulerAngles.z;

        float linearDuration = (targetPosition - startPosition).magnitude / linearMax;
        float angularDuration = Mathf.Abs(Mathf.DeltaAngle(startRotation, targetRotation)) / angularMax;
        duration = Mathf.Max(duration, linearDuration, angularDuration);

        do
        {
            elapsed += Time.deltaTime;
            float lerpTime = Mathf.Clamp01(elapsed / duration);
            float positionX = Mathf.Lerp(startPosition.x, targetPosition.x, lerpTime);
            float positionY = Mathf.Lerp(startPosition.y, targetPosition.y, lerpTime);
            float rotation = Mathf.LerpAngle(startRotation, targetRotation, lerpTime);
            transform.position = new Vector3(positionX, positionY, transform.position.z);
            transform.rotation = Quaternion.Euler(0f, 0f, rotation);
            yield return null;
        } while (elapsed < duration);
        toolCoroutine = null;
    }

    private void Interrupt(ref Coroutine coroutine)
    {
        if (coroutine != null)
        {
            StopCoroutine(coroutine);
            coroutine = null;
        }
    }

    void OnEnable()
    {
        
    }

    void OnDisable()
    {
        
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer != LayerMask.NameToLayer("Enemy"))
            return;
        Status status = collision.transform.GetComponent<Status>();
        status.ModifyHealth(-1f);

        Vector2 dir = (collision.transform.position - transform.position).normalized;
        Rigidbody2D collisionRb = collision.transform.GetComponent<Rigidbody2D>();
        collisionRb.linearVelocity = dir * 10f;

        if (status.health == 0)
            Destroy(collision.gameObject);
    }
}

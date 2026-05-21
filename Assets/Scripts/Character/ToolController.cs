using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class ToolController : MonoBehaviour
{
    [SerializeField] private Tool tool;
    [SerializeField] private Transform toolTransform;
    [SerializeField] private float linearMax;
    [SerializeField] private float linearSpeedMax;
    [SerializeField] private float angularSpeedMax;
    [SerializeField] private float linearScale;
    [SerializeField] private float angularScale;

    private Coroutine toolCoroutine;

    [SerializeField] private InputActionReference attack;
    [SerializeField] private InputActionReference defend;
    [SerializeField] private InputActionReference cancel;


    void Update()
    {
        Vector2 mouseDelta = Mouse.current.delta.ReadValue();
        float displacementX = mouseDelta.x * linearScale * transform.localScale.x;
        float angle = mouseDelta.y * angularScale;
        MoveToolBy(new Vector2(displacementX, 0), angle, Time.deltaTime);
    }

    private void MoveToolBy(Vector2 displacement, float angle, float duration)
    {
        Vector2 startPosition = new Vector2(toolTransform.localPosition.x, toolTransform.localPosition.y);
        Vector2 targetPosition = startPosition + displacement;
        float startRotation = toolTransform.localEulerAngles.z;
        float targetRotation = startRotation + angle;
        MoveToolTo(targetPosition, targetRotation, duration);
    }

    private void MoveToolTo(Vector2 targetPosition, float targetRotation, float duration)
    {
        targetPosition = new Vector2(
            Mathf.Clamp(targetPosition.x, -linearMax, linearMax),
            Mathf.Clamp(targetPosition.y, -linearMax, linearMax));

        if (toolCoroutine != null)
            return;
        toolCoroutine = StartCoroutine(MoveToolCoroutine(targetPosition, targetRotation, duration));
    }

    private IEnumerator MoveToolCoroutine(Vector2 targetPosition, float targetRotation, float duration)
    {
        float elapsed = 0f;
        Vector2 startPosition = new Vector2(toolTransform.localPosition.x, toolTransform.localPosition.y);
        float startRotation = toolTransform.localEulerAngles.z;

        float linearDuration = (targetPosition - startPosition).magnitude / linearSpeedMax;
        float angularDuration = Mathf.Abs(Mathf.DeltaAngle(startRotation, targetRotation)) / angularSpeedMax;
        duration = Mathf.Max(duration, linearDuration, angularDuration);

        do
        {
            elapsed += Time.deltaTime;
            float lerpTime = Mathf.Clamp01(elapsed / duration);
            float positionX = Mathf.Lerp(startPosition.x, targetPosition.x, lerpTime);
            float positionY = Mathf.Lerp(startPosition.y, targetPosition.y, lerpTime);
            float rotation = Mathf.LerpAngle(startRotation, targetRotation, lerpTime);
            toolTransform.localPosition = new Vector3(positionX, positionY, toolTransform.localPosition.z);
            toolTransform.localRotation = Quaternion.Euler(0f, 0f, rotation);
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
        attack.action.started += Attack;
        defend.action.started += Defend;
        cancel.action.started += Cancel;
    }

    void OnDisable()
    {
        attack.action.started -= Attack;
        defend.action.started -= Defend;
        cancel.action.started -= Cancel;
    }

    private void Attack(InputAction.CallbackContext obj)
    {

    }

    private void Defend(InputAction.CallbackContext obj)
    {

    }

    private void Cancel(InputAction.CallbackContext obj)
    {
        Interrupt(ref toolCoroutine);
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer != LayerMask.NameToLayer("Enemy"))
            return;
        Status status = collision.transform.GetComponent<Status>();
        status.ModifyHealth(-1f);

        Vector2 dir = (collision.transform.position - toolTransform.position).normalized;
        Rigidbody2D collisionRb = collision.transform.GetComponent<Rigidbody2D>();
        collisionRb.linearVelocity = dir * 10f;

        if (status.health == 0)
            Destroy(collision.gameObject);
    }
}

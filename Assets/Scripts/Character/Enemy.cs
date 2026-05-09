using UnityEngine;

public class Enemy : MonoBehaviour
{
    [SerializeField] private float speed;
    [SerializeField] private float jumpForce;
    [SerializeField] private float jumpCooldown;
    private float jumpTimer;

    private Rigidbody2D rb;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    void Update()
    {
        jumpTimer += Time.deltaTime;
        if (jumpTimer > jumpCooldown)
        {
            jumpTimer -= jumpCooldown;
            float angle = Random.Range(30f, 150f);
            float rad = angle * Mathf.Deg2Rad;
            rb.linearVelocity = new Vector2(Mathf.Cos(rad), Mathf.Sin(rad)) * jumpForce;
        }
    }

    void FixedUpdate()
    {
        if (rb.linearVelocityX > 0.1f)
            transform.localScale = new Vector3(1, 1, 1);
        else if (rb.linearVelocityX < -0.1f)
            transform.localScale = new Vector3(-1, 1, 1);
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.layer != LayerMask.NameToLayer("Player"))
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

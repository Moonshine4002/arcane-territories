using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [SerializeField] private float speed;
    [SerializeField] private float jumpForce;

    private Rigidbody2D rb;
    private BoxCollider2D col;
    [SerializeField] private LayerMask groundLayer;
    private Animator anim;
    [SerializeField] private InputActionReference move;
    private Vector2 moveInput;
    [SerializeField] private InputActionReference jump;
    //private bool jumpInput;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        col = GetComponent<BoxCollider2D>();
        anim = GetComponent<Animator>();
    }

    void Update()
    {
        moveInput = move.action.ReadValue<Vector2>();
        //jumpInput = jump.action.IsPressed();
        anim.SetBool("move", moveInput.x != 0);
        anim.SetBool("grounded", IsGrounded());
    }

    void FixedUpdate()
    {
        rb.linearVelocityX = moveInput.x * speed;
        if (rb.linearVelocityX > 0.1f)
            transform.localScale = new Vector3(1, 1, 1);
        else if (rb.linearVelocityX < -0.1f)
            transform.localScale = new Vector3(-1, 1, 1);
    }

    void OnEnable()
    {
        jump.action.started += Jump;
    }

    void OnDisable()
    {
        jump.action.started -= Jump;
    }

    private void Jump(InputAction.CallbackContext obj)
    {
        if (!IsGrounded())
            return;
        rb.linearVelocityY = jumpForce;
        anim.SetTrigger("jump");
    }

    private bool IsGrounded()
    {
        RaycastHit2D raycastHit = Physics2D.BoxCast(col.bounds.center, col.bounds.size, 0, Vector2.down, 0.1f, groundLayer);
        return raycastHit.collider != null;
    }
}

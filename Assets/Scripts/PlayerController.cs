using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public float speed = 1f;
    public float jumpForce = 1f;

    public Rigidbody2D rb;
    public BoxCollider2D bc;
    public LayerMask groundLayer;
    public Animator anim;
    public InputActionReference move;
    public Vector2 moveInput;
    public InputActionReference jump;
    //public bool jumpInput;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        bc = GetComponent<BoxCollider2D>();
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
        if (rb.linearVelocityX > 0)
            transform.localScale = new Vector3(1, 1, 1);
        else if (rb.linearVelocityX < 0)
            transform.localScale = new Vector3(-1, 1, 1);
    }

    private void OnEnable()
    {
        jump.action.started += Jump;
    }

    private void OnDisable()
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

    public bool IsGrounded()
    {
        RaycastHit2D raycastHit = Physics2D.BoxCast(bc.bounds.center, bc.bounds.size, 0, Vector2.down, 0.1f, groundLayer);
        return raycastHit.collider != null;
    }
}

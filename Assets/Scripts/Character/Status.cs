using UnityEngine;

public class Status : MonoBehaviour
{
    public float health;
    public float healthMax;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void ModifyHealth(float value)
    {
        health = Mathf.Clamp(health + value, 0, healthMax);
    }
}

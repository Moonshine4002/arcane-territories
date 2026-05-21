using UnityEngine;

public class Status : MonoBehaviour
{
    public float health;
    public float healthMax;

    public void ModifyHealth(float value)
    {
        health = Mathf.Clamp(health + value, 0, healthMax);
    }
}

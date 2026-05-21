using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI : MonoBehaviour
{
    [SerializeField] private Status status;
    [SerializeField] private RectTransform healthBar;
    [SerializeField] private Image heart;
    private List<Image> hearts = new();

    void Update()  // TODO: event
    {
        RefreshHearts();
        for (int i = 0; i < hearts.Count; i++)
        {
            float remain = status.health - i;
            hearts[i].fillAmount = Mathf.Clamp01(remain);
        }
    }

    private void RefreshHearts()
    {
        while (status.healthMax > hearts.Count)
        {
            hearts.Add(Instantiate(heart, healthBar));
        }
    }
}

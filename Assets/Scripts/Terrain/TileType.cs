using System;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Tile/TileType")]
public class TileType : ScriptableObject
{
    [NonSerialized] public List<Sprite> sprites = new();
    public Color color;
    public bool isSolid;
}

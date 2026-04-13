using System;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Tile/TileType")]
public class TileType : ScriptableObject
{
    public int id;

    public Color color;

    public bool isSolid;

    public List<string> spriteNames;
    [NonSerialized]
    public List<Sprite> sprites = new List<Sprite>();
    
    public void Init()
    {
        foreach (string name in spriteNames)
        {
            sprites.Add(TileDatabase.atlas.GetSprite(name));
        }
    }
}

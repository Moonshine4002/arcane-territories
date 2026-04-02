using System;
using UnityEngine;
using UnityEngine.U2D;

[CreateAssetMenu(menuName = "Tile/TileType")]
public class TileType : ScriptableObject
{
    public int id;

    public Color color;

    public bool isSolid;

    public SpriteAtlas atlas;
    public string[] sprites;

    public Sprite GetSprite()
    {
        return atlas.GetSprite(sprites[0]);
    }
}

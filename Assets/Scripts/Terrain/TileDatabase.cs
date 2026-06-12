using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;

public class TileDatabase
{
    public static SpriteAtlas atlas;
    public static Texture2D tex;
    public static Dictionary<string, TileType> tileTypes = new(StringComparer.OrdinalIgnoreCase);

    public static void Init()
    {
        atlas = Resources.Load<SpriteAtlas>("kenney_voxel-pack");
        Sprite[] allSprites = new Sprite[atlas.spriteCount];
        atlas.GetSprites(allSprites);
        tex = allSprites.Length > 0 ? allSprites[0].texture : null;
        foreach (var tileType in Resources.LoadAll<TileType>("Tiles"))
        {
            tileTypes[tileType.name] = tileType;
            foreach (var sprite in allSprites)
            {
                if (sprite.name.StartsWith(tileType.name, StringComparison.OrdinalIgnoreCase))
                {
                    tileType.sprites.Add(sprite);
                }
            }
        }
    }

    public static TileType Get(string name)
    {
        return tileTypes[name];
    }
}

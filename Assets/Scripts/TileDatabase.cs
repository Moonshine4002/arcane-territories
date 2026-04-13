using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;

public class TileDatabase
{
    static public SpriteAtlas atlas;
    static public Texture2D tex;

    public static Dictionary<int, TileType> tileTypes;

    public static void Init()
    {
        atlas = Resources.Load<SpriteAtlas>("Sprites/kenney_voxel-pack");
        tex = atlas.GetSprite("stone").texture;  // TODO

        tileTypes = new Dictionary<int, TileType>();
        foreach (var tileType in Resources.LoadAll<TileType>("Assets/Tiles"))
        {
            tileType.Init();
            tileTypes[tileType.id] = tileType;
        }
    }

    public static TileType Get(int id)
    {
        return tileTypes[id];
    }
}

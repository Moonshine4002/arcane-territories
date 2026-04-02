using System.Collections.Generic;
using UnityEngine;

public class TileDatabase
{
    public static Dictionary<int, TileType> tiles;

    public static void Init()
    {
        tiles = new Dictionary<int, TileType>();
        foreach (var tile in Resources.LoadAll<TileType>("Assets/Tiles"))
        {
            tiles[tile.id] = tile;
        }
    }

    public static TileType Get(int id)
    {
        return tiles[id];
    }
}

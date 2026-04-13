using UnityEngine;

public class Chunk
{
    public Vector2Int coord;
    public Tile[,] tiles;
    public int size;
    public bool isDirty = false;

    public Chunk(Vector2Int coord, Texture2D tex)
    {
        this.coord = coord;
        size = 16;  // TODO: to config
        tiles = new Tile[size,size];
        for (int x = 0; x < size; x++)
        {
            for (int y = 0; y < size; y++)
            {
                Vector2Int worldCoord = LocalToWorld(new Vector2Int(x, y));
                Color color = tex.GetPixel(worldCoord.x, worldCoord.y);
                SetTile(x, y, 0, 0);  // TODO
                foreach (var kvp in TileDatabase.tileTypes)
                {
                    if (Vector4.Distance(kvp.Value.color, color) >= 0.01f)
                        continue;
                    SetTile(x, y, kvp.Value.id, 0);  // TODO
                }
            }
        }
    }

    public bool SetTile(int x, int y, int type, int variant)
    {
        if (!InBounds(x, y))
            return false;

        tiles[x, y] = new Tile { type = type, variant = variant };
        isDirty = true;
        return true;
    }

    public Tile GetTile(int x, int y)
    {
        if (!InBounds(x, y))
            return default;

        return tiles[x, y];
    }

    public bool RemoveTile(int x, int y)
    {
        if (!InBounds(x, y))
            return false;

        if (tiles[x, y].type == 0)
            return false;

        tiles[x, y] = new Tile { type = 0, variant = 0 };
        isDirty = true;
        return true;
    }

    public bool InBounds(int x, int y)
    {
        return x >= 0 && x < size && y >= 0 && y < size;
    }

    public Vector2Int WorldToLocal(Vector2Int worldCoord)
    {
        int localX = worldCoord.x - coord.x * size;
        int localY = worldCoord.y - coord.y * size;

        return new Vector2Int(localX, localY);
    }

    public Vector2Int LocalToWorld(Vector2Int localCoord)
    {
        int worldX = coord.x * size + localCoord.x;
        int worldY = coord.y * size + localCoord.y;

        return new Vector2Int(worldX, worldY);
    }
}

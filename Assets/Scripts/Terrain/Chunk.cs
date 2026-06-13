using System.Collections.Generic;
using UnityEngine;

public class Chunk
{
    public int size => Main.Config.chunkSize;
    public Vector2Int coord;
    public Tile[,] tiles;
    public bool isDirty = true;

    public List<Vector3> vertices = new();
    public List<int> triangles = new();
    public List<Vector2> uvs = new();
    public bool[,] colliders;

    public Chunk(Vector2Int coord, Texture2D tex)
    {
        this.coord = coord;
        tiles = new Tile[size, size];
        for (int x = 0; x < size; x++)
            for (int y = 0; y < size; y++)
            {
                Vector2Int worldCoord = LocalToWorld(new Vector2Int(x, y));
                Color color = tex.GetPixel(worldCoord.x, worldCoord.y);
                SetTile(x, y, "");
                foreach (var kvp in TileDatabase.tileTypes)
                {
                    if (Vector4.Distance(kvp.Value.color, color) >= 0.01f)
                        continue;
                    SetTile(x, y, kvp.Value.name);
                }
            }
        colliders = new bool[size, size];
    }

    public bool SetTile(int x, int y, string name)
    {
        if (!InBounds(x, y))
            return false;

        tiles[x, y] = new Tile { name = name };
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

        if (tiles[x, y].name == "")
            return false;

        tiles[x, y] = new Tile { name = "" };
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

    public void Cleanse()
    {
        vertices.Clear();
        triangles.Clear();
        uvs.Clear();
        System.Array.Clear(colliders, 0, colliders.Length);
        for (int x = 0; x < size; x++)
            for (int y = 0; y < size; y++)
            {
                Tile tile = tiles[x, y];
                if (tile.name == "")
                    continue;
                TileType tileType = TileDatabase.Get(tile.name);
                if (tileType.sprites.Count == 0)
                    continue;
                Sprite sprite = tileType.sprites[Random.Range(0, tileType.sprites.Count)];
                AddQuad(x, y, sprite);
                colliders[x, y] = tileType.isSolid;
            }
    }

    public void AddQuad(int x, int y, Sprite sprite)
    {
        int index = vertices.Count;

        vertices.Add(new Vector3(x, y, 0));
        vertices.Add(new Vector3(x + 1, y, 0));
        vertices.Add(new Vector3(x, y + 1, 0));
        vertices.Add(new Vector3(x + 1, y + 1, 0));

        triangles.Add(index + 0);
        triangles.Add(index + 2);
        triangles.Add(index + 1);

        triangles.Add(index + 1);
        triangles.Add(index + 2);
        triangles.Add(index + 3);

        Vector2[] spriteUV = sprite.uv;
        uvs.Add(spriteUV[2]);
        uvs.Add(spriteUV[3]);
        uvs.Add(spriteUV[0]);
        uvs.Add(spriteUV[1]);
    }
}

public static class ChunkCoord
{
    public static int Size => Main.Config.chunkSize;

    public static Vector2Int WorldToChunk(Vector2Int worldCoord)
    {
        int chunkX = Mathf.FloorToInt((float)worldCoord.x / Size);
        int chunkY = Mathf.FloorToInt((float)worldCoord.y / Size);
        return new Vector2Int(chunkX, chunkY);
    }

    public static Vector2Int ChunkToWorld(Vector2Int chunkCoord)
    {
        int worldX = chunkCoord.x * Size;
        int worldY = chunkCoord.y * Size;
        return new Vector2Int(worldX, worldY);
    }
}

using System.Collections.Generic;
using UnityEngine;

static public class MeshBuilder
{
    static public List<Vector3> vertices = new List<Vector3>();
    static public List<int> triangles = new List<int>();
    static public List<Vector2> uvs = new List<Vector2>();

    static public void Build(Chunk chunk, ChunkView view)
    {
        vertices.Clear();
        triangles.Clear();
        uvs.Clear();
        for (int x = 0; x < chunk.size; x++)
        {
            for (int y = 0; y < chunk.size; y++)
            {
                Tile tile = chunk.tiles[x, y];
                if (tile.type == 0)
                    continue;
                AddQuad(x, y, tile);
            }
        }
        view.SetMesh(vertices, triangles, uvs);
    }

    static void AddQuad(int x, int y, Tile tile)
    {
        int index = vertices.Count;

        vertices.Add(new Vector3(x, y, 0));
        vertices.Add(new Vector3(x + 1, y, 0));
        vertices.Add(new Vector3(x + 1, y + 1, 0));
        vertices.Add(new Vector3(x, y + 1, 0));

        triangles.Add(index + 0);
        triangles.Add(index + 2);
        triangles.Add(index + 1);

        triangles.Add(index + 0);
        triangles.Add(index + 3);
        triangles.Add(index + 2);

        TileType tileType = TileDatabase.Get(tile.type);
        Sprite sprite = tileType.sprites[tile.variant];
        Vector2[] spriteUV = sprite.uv;
        uvs.Add(spriteUV[2]);
        uvs.Add(spriteUV[3]);
        uvs.Add(spriteUV[1]);
        uvs.Add(spriteUV[0]);
    }
}

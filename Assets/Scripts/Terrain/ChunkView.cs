using TMPro;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ChunkView : MonoBehaviour
{
    public Chunk chunk;
    public MeshFilter meshFilter;
    public Mesh mesh;
    public MeshRenderer meshRenderer;
    static public Material sharedMaterial;
    //public MeshCollider meshCollider;

    void Awake()
    {
        if (sharedMaterial == null)
            sharedMaterial = new Material(Shader.Find("Sprites/Default"));
        sharedMaterial.mainTexture = TileDatabase.tex;

        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        mesh = new Mesh();
        meshRenderer.material = sharedMaterial;

        var rb = gameObject.AddComponent<Rigidbody2D>();
        rb.bodyType = RigidbodyType2D.Static;
        gameObject.AddComponent<CompositeCollider2D>();
    }

    public void Init(Chunk chunk)
    {
        this.chunk = chunk;
    }

    public void Cleanse()
    {
        if (!chunk.isDirty)
            return;

        chunk.Cleanse();
        chunk.isDirty = false;

        mesh.Clear();
        mesh.SetVertices(chunk.vertices);
        mesh.SetTriangles(chunk.triangles, 0);
        mesh.SetUVs(0, chunk.uvs);
        // mesh.RecalculateNormals();
        meshFilter.sharedMesh = mesh;

        bool[,] mask = new bool[chunk.size, chunk.size];
        System.Array.Copy(chunk.colliders, mask, chunk.colliders.Length);
        for (int x = 0; x < chunk.size; x++)
            for (int y = 0; y < chunk.size; y++)
            {
                if (!mask[x, y])
                    continue;
                int w, h;
                for (w = 1; x + w < chunk.size; w++)
                {
                    if (!mask[x + w, y])
                        break;
                }
                for (h = 1; y + h < chunk.size; h++)
                {
                    bool flag = true;
                    for (int i = x; i < x + w; i++)
                    {
                        if (!mask[i, y + h])
                        {
                            flag = false;
                            break;
                        }
                    }
                    if (!flag)
                        break;
                }
                for (int i = x; i < x + w; i++)
                    for (int j = y; j < y + h; j++)
                        mask[i, j] = false;

                var col = gameObject.AddComponent<BoxCollider2D>();
                col.compositeOperation = Collider2D.CompositeOperation.Merge;
                col.offset = new Vector2(x + w * 0.5f, y + h * 0.5f);
                col.size = new Vector2(w, h);
            }
    }

    void OnDestroy()
    {
        Destroy(mesh);
    }
}

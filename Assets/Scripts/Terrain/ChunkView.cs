using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ChunkView : MonoBehaviour
{
    public Chunk chunk;
    public Mesh mesh;
    static public Material sharedMaterial;
    public MeshFilter meshFilter;
    public MeshRenderer meshRenderer;
    public MeshCollider meshCollider;

    void Awake()
    {
        if (sharedMaterial == null)
            sharedMaterial = new Material(Shader.Find("Sprites/Default"));
        sharedMaterial.mainTexture = TileDatabase.tex;

        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        mesh = new Mesh();
        meshRenderer.material = sharedMaterial;
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
    }

    void OnDestroy()
    {
        Destroy(mesh);
    }
}

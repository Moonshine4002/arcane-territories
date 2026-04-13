using System.Collections.Generic;
using UnityEngine;

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
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void Init(Chunk chunk)
    {
        this.chunk = chunk;
        meshFilter = gameObject.AddComponent<MeshFilter>();
        meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshCollider = gameObject.AddComponent<MeshCollider>();

        mesh = new Mesh();
        meshFilter.sharedMesh = mesh;
        meshCollider.sharedMesh = mesh;
        meshRenderer.material = sharedMaterial;

        sharedMaterial.mainTexture = TileDatabase.tex;
    }

    void OnDestroy()
    {
        Destroy(mesh);
    }

    public void SetMesh(List<Vector3> vertices, List<int> triangles, List<Vector2> uvs)
    {
        mesh.Clear();
        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles, 0);
        mesh.SetUVs(0, uvs);
        // mesh.RecalculateNormals();
    }
}

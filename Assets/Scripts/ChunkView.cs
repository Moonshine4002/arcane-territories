using UnityEngine;

public class ChunkView : MonoBehaviour
{
    public Chunk chunk;
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
        meshRenderer.material = sharedMaterial;
        TileType tileType = TileDatabase.Get(chunk.tiles[0, 0].type);  // TODO
        meshRenderer.material.mainTexture = tileType.GetSprite().texture;
    }

    public void SetMesh(Mesh mesh)
    {
        meshFilter.sharedMesh = mesh;
        meshCollider.sharedMesh = mesh;
    }
}

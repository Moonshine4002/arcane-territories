using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
    public static WorldConfig Config;

    public int seed;
    public int seedRange = 100;
    public int width = 64;
    public int height = 48;
    public Texture2D map;
    public Dictionary<Vector2Int, Chunk> chunks;
    public Dictionary<Vector2Int, ChunkView> chunkViews;

    public float scaleMicro = 0.2f;
    public float scaleMeso = 0.02f;
    public float scaleMacro = 0.002f;
    public float scaleSlopeMicroLeft = -0.002f;
    public float scaleSlopeMicroRight = 0.003f;
    public float scaleSlopeMesoLeft = -0.02f;
    public float scaleSlopeMesoRight = 0.03f;
    public float scaleSlopeMacroLeft = -0.2f;
    public float scaleSlopeMacroRight = 0.3f;
    public float scaleCave = 0.02f;
    public float oddCave = 0.25f;
    public float scaleOre = 0.05f;
    public float scaleBiomeX = 0.002f;
    public float scaleBiomeY = 0.001f;
    public float oddWater = 0.2f;
    public float oddFire = 0.2f;
    public float oddAir = 0.2f;
    public float oddEarth = 0.2f;
    public float oddLight = 0.2f;
    public float oddLife = 0.2f;

    public Transform player;
    public Vector2Int lastChunkCoord;

    void Awake()
    {
        if (Config == null)
            Config = Resources.Load<WorldConfig>("Configs/World");
        TileDatabase.Init();
    }

    void Start()
    {
        seed = Random.Range(0, seedRange);
        chunks = new Dictionary<Vector2Int, Chunk>();
        chunkViews = new Dictionary<Vector2Int, ChunkView>();

        Generate();
    }

    //void OnValidate()
    //{
    //    Generate();
    //}

    void Update()
    {
        Render(player.position);
    }

    void Generate()
    {
        int seedSeaLevel = GetSeed(seed, "seaLevel");
        int seedAltitudeMicro = GetSeed(seed, "altitudeMicro");
        int seedAltitudeMeso = GetSeed(seed, "altitudeMeso");
        int seedAltitudeMacro = GetSeed(seed, "altitudeMacro");
        int seedCave = GetSeed(seed, "cave");
        int seedWater = GetSeed(seed, "water");
        int seedFire = GetSeed(seed, "fire");
        int seedAir = GetSeed(seed, "air");
        int seedEarth = GetSeed(seed, "earth");
        int seedLight = GetSeed(seed, "light");
        int seedLife = GetSeed(seed, "life");
        int seedWaterBiome = GetSeed(seed, "waterBiome");
        int seedFireBiome = GetSeed(seed, "fireBiome");
        int seedAirBiome = GetSeed(seed, "airBiome");
        int seedEarthBiome = GetSeed(seed, "earthBiome");
        int seedLightBiome = GetSeed(seed, "lightBiome");
        int seedLifeBiome = GetSeed(seed, "lifeBiome");
        Vector2Int size = ChunkCoord.ChunkToWorld(new Vector2Int(width, height));
        map = new Texture2D(size.x, size.y);
        float seaLevel = Mathf.Lerp(0.5f, 0.7f, Perlin(0, 0, seedSeaLevel, 0, 0));
        for (int x = 0; x < map.width; x++)
        {
            for (int y = 0; y < map.height; y++)
            {
                float sampleAltitudeMicro = Mathf.Lerp(scaleSlopeMicroLeft, scaleSlopeMicroRight, Perlin(x, 0, seedAltitudeMicro, scaleMicro, scaleMicro));
                float sampleAltitudeMeso = Mathf.Lerp(scaleSlopeMesoLeft, scaleSlopeMesoRight, Perlin(x, 0, seedAltitudeMeso, scaleMeso, scaleMeso));
                float sampleAltitudeMacro = Mathf.Lerp(scaleSlopeMacroLeft, scaleSlopeMacroRight, Perlin(x, 0, seedAltitudeMacro, scaleMacro, scaleMacro));
                float sampleCave = Perlin(x, y, seedCave, scaleCave, scaleCave);
                float sampleWater = Perlin(x, y, seedWater, scaleOre, scaleOre);
                float sampleFire = Perlin(x, y, seedFire, scaleOre, scaleOre);
                float sampleAir = Perlin(x, y, seedAir, scaleOre, scaleOre);
                float sampleEarth = Perlin(x, y, seedEarth, scaleOre, scaleOre);
                float sampleLight = Perlin(x, y, seedLight, scaleOre, scaleOre);
                float sampleLife = Perlin(x, y, seedLife, scaleOre, scaleOre);
                float sampleWaterBiome = Perlin(x, y, seedWaterBiome, scaleBiomeX, scaleBiomeY);
                float sampleFireBiome = Perlin(x, y, seedFireBiome, scaleBiomeX, scaleBiomeY);
                float sampleAirBiome = Perlin(x, y, seedAirBiome, scaleBiomeX, scaleBiomeY);
                float sampleEarthBiome = Perlin(x, y, seedEarthBiome, scaleBiomeX, scaleBiomeY);
                float sampleLightBiome = Perlin(x, y, seedLightBiome, scaleBiomeX, scaleBiomeY);
                float sampleLifeBiome = Perlin(x, y, seedLifeBiome, scaleBiomeX, scaleBiomeY);
                if ((seaLevel + sampleAltitudeMicro + sampleAltitudeMeso + sampleAltitudeMacro) * map.height < y)
                {
                    if (seaLevel * map.height < y)
                        map.SetPixel(x, y, new Color(0, 1, 1));
                    else
                        map.SetPixel(x, y, new Color(0, 0.5f, 0.5f));
                }
                else if (sampleCave < oddCave)
                    map.SetPixel(x, y, new Color(0, 0, 0));
                else
                {
                    if (sampleWater < Random.Range(0, sampleWaterBiome) * oddWater)
                        map.SetPixel(x, y, new Color(0.0f, 0.4f, 0.8f));
                    else if (sampleFire < Random.Range(0, sampleFireBiome) * oddFire)
                        map.SetPixel(x, y, new Color(0.9f, 0.2f, 0.1f));
                    else if (sampleAir < Random.Range(0, sampleAirBiome) * oddAir)
                        map.SetPixel(x, y, new Color(0.8f, 0.8f, 0.9f));
                    else if (sampleEarth < Random.Range(0, sampleEarthBiome) * oddEarth)
                        map.SetPixel(x, y, new Color(0.5f, 0.3f, 0.1f));
                    else if (sampleLight < Random.Range(0, sampleLightBiome) * oddLight)
                        map.SetPixel(x, y, new Color(1.0f, 0.95f, 0.7f));
                    else if (sampleLife < Random.Range(0, sampleLifeBiome) * oddLife)
                        map.SetPixel(x, y, new Color(0.3f, 0.6f, 0.2f));
                    else
                        map.SetPixel(x, y, new Color(1, 1, 1));
                }
            }
        }
        map.Apply();
    }

    int GetSeed(int seed, string str)
    {
        return (seed.ToString() + str).GetHashCode() % seedRange;
    }

    float Perlin(int x, int y, int seed, float scaleX, float scaleY)
    {
        float xPerlin = x * scaleX + seed;
        float yPerlin = y * scaleY + seed;
        float sample = Mathf.PerlinNoise(xPerlin, yPerlin);
        return sample;
    }

    void Render(Vector2 pos)
    {
        int distanceUpdate = 16;
        int distanceRender = 3;
        Vector2Int chunkCoord = ChunkCoord.WorldToChunk(Vector2Int.FloorToInt(pos));
        if (lastChunkCoord == chunkCoord)
            return;
        else
            lastChunkCoord = chunkCoord;

        HashSet<Vector2Int> visibleChunks = new HashSet<Vector2Int>();
        for (int x = chunkCoord.x - distanceRender; x <= chunkCoord.x + distanceRender; x++)
        {
            for (int y = chunkCoord.y - distanceRender; y <= chunkCoord.y + distanceRender; y++)
            {
                visibleChunks.Add(new Vector2Int(x, y));
            }
        }

        foreach (var coord in visibleChunks)
        {
            if (!chunks.TryGetValue(coord, out Chunk chunk))
            {
                chunk = new Chunk(coord, map);
                chunks.Add(coord, chunk);
            }

            if (!chunkViews.TryGetValue(coord, out ChunkView chunkView))
            {
                GameObject obj = new GameObject($"Chunk ({coord.x}, {coord.y})");
                obj.transform.parent = transform;
                obj.transform.position = (Vector2)ChunkCoord.ChunkToWorld(coord);
                chunkView = obj.AddComponent<ChunkView>();
                chunkView.Init(chunk);
                chunkViews.Add(coord, chunkView);
            }
            else
                chunkView.gameObject.SetActive(true);
            chunkView.Cleanse();
        }

        HashSet<Vector2Int> toRemove = new HashSet<Vector2Int>(chunkViews.Keys);
        toRemove.ExceptWith(visibleChunks);
        foreach (var key in toRemove)
        {
            chunkViews[key].gameObject.SetActive(false);
        }
    }
}

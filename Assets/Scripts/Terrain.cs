using UnityEngine;

public class Terrain : MonoBehaviour
{
    public int seed;
    public int seedRange = 100;
    public int chunk = 16;
    public int width = 64;
    public int height = 48;
    public float scaleMicro = 0.2f;
    public float scaleMeso = 0.02f;
    public float scaleMacro = 0.002f;
    public float scaleSlopeMicroLeft = -0.002f;
    public float scaleSlopeMicroRight = 0.003f;
    public float scaleSlopeMesoLeft = -0.02f;
    public float scaleSlopeMesoRight = 0.03f;
    public float scaleSlopeMacroLeft = -0.2f;
    public float scaleSlopeMacroRight = 0.3f;
    public float scaleCave = 0.05f;
    public float oddCave = 0.25f;
    public float scaleBiomeX = 0.002f;
    public float scaleBiomeY = 0.001f;
    public float oddWater = 0.5f;
    public float oddFire = 0.5f;
    public float oddAir = 0.5f;
    public float oddEarth = 0.5f;
    public float oddLight = 0.5f;
    public float oddLife = 0.5f;

    public Texture2D map;

    void Start()
    {
        seed = Random.Range(0, seedRange);

        Generate();
    }

    void OnValidate()
    {
        Generate();
    }

    void Update()
    {

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
        map = new Texture2D(width * chunk, height * chunk);
        float seaLevel = Mathf.Lerp(0.5f, 0.7f, Perlin(0, 0, seedSeaLevel, 0, 0));
        for (int x = 0; x < map.width; x++)
        {
            for (int y = 0; y < map.height; y++)
            {
                float sampleAltitudeMicro = Mathf.Lerp(scaleSlopeMicroLeft, scaleSlopeMicroRight, Perlin(x, 0, seedAltitudeMicro, scaleMicro, scaleMicro));
                float sampleAltitudeMeso = Mathf.Lerp(scaleSlopeMesoLeft, scaleSlopeMesoRight, Perlin(x, 0, seedAltitudeMeso, scaleMeso, scaleMeso));
                float sampleAltitudeMacro = Mathf.Lerp(scaleSlopeMacroLeft, scaleSlopeMacroRight, Perlin(x, 0, seedAltitudeMacro, scaleMacro, scaleMacro));
                float sampleCave = Perlin(x, y, seedCave, scaleCave, scaleCave);
                float sampleWater = Perlin(x, y, seedWater, scaleCave, scaleCave);
                float sampleFire = Perlin(x, y, seedFire, scaleCave, scaleCave);
                float sampleAir = Perlin(x, y, seedAir, scaleCave, scaleCave);
                float sampleEarth = Perlin(x, y, seedEarth, scaleCave, scaleCave);
                float sampleLight = Perlin(x, y, seedLight, scaleCave, scaleCave);
                float sampleLife = Perlin(x, y, seedLife, scaleCave, scaleCave);
                float sampleWaterBiome = Perlin(x, y, seedWaterBiome, scaleBiomeX, scaleBiomeY) * oddWater;
                float sampleFireBiome = Perlin(x, y, seedFireBiome, scaleBiomeX, scaleBiomeY) * oddFire;
                float sampleAirBiome = Perlin(x, y, seedAirBiome, scaleBiomeX, scaleBiomeY) * oddAir;
                float sampleEarthBiome = Perlin(x, y, seedEarthBiome, scaleBiomeX, scaleBiomeY) * oddEarth;
                float sampleLightBiome = Perlin(x, y, seedLightBiome, scaleBiomeX, scaleBiomeY) * oddLight;
                float sampleLifeBiome = Perlin(x, y, seedLifeBiome, scaleBiomeX, scaleBiomeY) * oddLife;
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
                    if (sampleWater < Random.Range(0, sampleWaterBiome))
                        map.SetPixel(x, y, new Color(0.0f, 0.4f, 0.8f));
                    else if (sampleFire < Random.Range(0, sampleFireBiome))
                        map.SetPixel(x, y, new Color(0.9f, 0.2f, 0.1f));
                    else if (sampleAir < Random.Range(0, sampleAirBiome))
                        map.SetPixel(x, y, new Color(0.8f, 0.8f, 0.9f));
                    else if (sampleEarth < Random.Range(0, sampleEarthBiome))
                        map.SetPixel(x, y, new Color(0.5f, 0.3f, 0.1f));
                    else if (sampleLight < Random.Range(0, sampleLightBiome))
                        map.SetPixel(x, y, new Color(1.0f, 0.95f, 0.7f));
                    else if (sampleLife < Random.Range(0, sampleLifeBiome))
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
}

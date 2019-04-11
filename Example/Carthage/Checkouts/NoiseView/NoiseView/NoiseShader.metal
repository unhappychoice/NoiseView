#include <metal_stdlib>

using namespace metal;

float rand(int x, int y, float time);
float4 noiseColor(int x, int y, float time);

kernel void adjust_noise(texture2d<float, access::write> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         constant float &time [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]]) {
    float4 outColor;
    outColor = noiseColor(gid.x, gid.y, time);
    outTexture.write(outColor, gid);
}

float4 noiseColor(int x, int y, float time) {
    float xVal = x / 2;
    float yVal = y / 2;
    float colorVal = 256.0 * rand(xVal, yVal, time);

    return float4(colorVal/255.0, colorVal/255.0, colorVal/255.0, 1.0);
}

float rand(int x, int y, float time) {
    int seed = x + y * 57 * 241 + (int)time * 21 * 129;
    seed = (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

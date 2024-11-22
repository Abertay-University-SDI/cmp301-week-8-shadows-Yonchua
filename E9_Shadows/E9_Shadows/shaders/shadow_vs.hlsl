Texture2D heightMap : register(t0);
SamplerState samplerState : register(s0);

cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
    matrix lightViewMatrix1;
    matrix lightProjectionMatrix1;
    matrix lightViewMatrix2;
    matrix lightProjectionMatrix2;
};

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos1 : TEXCOORD1;
    float4 lightViewPos2 : TEXCOORD2;
};

float GetHeight(float2 uv)
{
    // Sample the heightmap texture and use the red channel as the height value
    float offset = heightMap.SampleLevel(samplerState, uv, 0).r;
    return offset * 30.0f;
}

OutputType main(InputType input)
{
    OutputType output;

    float height = GetHeight(input.tex);

    // Offset the vertex position along the normal using the height value
    float3 offsetPosition = input.position.xyz + (normalize(input.normal) * height);
    float4 displacedPosition = float4(offsetPosition, 1.0);
    
    // Transform vertex position to world, view, and projection space
    output.position = mul(displacedPosition, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);

    // Calculate positions from each light’s perspective
    output.lightViewPos1 = mul(input.position, worldMatrix);
    output.lightViewPos1 = mul(output.lightViewPos1, lightViewMatrix1);
    output.lightViewPos1 = mul(output.lightViewPos1, lightProjectionMatrix1);

    output.lightViewPos2 = mul(input.position, worldMatrix);
    output.lightViewPos2 = mul(output.lightViewPos2, lightViewMatrix2);
    output.lightViewPos2 = mul(output.lightViewPos2, lightProjectionMatrix2);

    // Pass texture coordinates and transformed normal
    output.tex = input.tex;
    output.normal = normalize(mul(input.normal, (float3x3)worldMatrix));

    return output;
}
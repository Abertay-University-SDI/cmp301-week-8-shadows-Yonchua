Texture2D shaderTexture : register(t0);
Texture2D depthMapTexture1 : register(t1);  // Shadow map for first light
Texture2D depthMapTexture2 : register(t2);  // Shadow map for second light

SamplerState diffuseSampler  : register(s0);
SamplerState shadowSampler : register(s1);

cbuffer LightBuffer : register(b0)
{
    float4 ambient;
    float4 diffuse;
    float3 direction1;  // Direction for first light
    float padding1;
    float4 ambient2;
    float4 diffuse2;
    float3 direction2;  // Direction for second light
    float padding2;             
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos1 : TEXCOORD1;  // Light view position for first light
    float4 lightViewPos2 : TEXCOORD2;  // Light view position for second light
};

// Calculate lighting intensity based on direction and normal. Combine with light color.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    return saturate(diffuse * intensity);
}

// Check if the UV coordinates are within the shadow map's bounds
bool hasDepthData(float2 uv)
{
    return (uv.x >= 0.f && uv.x <= 1.f && uv.y >= 0.f && uv.y <= 1.f);
}

// Function to calculate shadows from a single light’s shadow map
float isInShadow(Texture2D shadowMap, float2 uv, float4 lightViewPosition, float bias)
{
    float depthValue = shadowMap.Sample(shadowSampler, uv).r;
    float lightDepth = lightViewPosition.z / lightViewPosition.w - bias;

    // Return 1.0 if not in shadow, 0.0 if in shadow
    return (lightDepth < depthValue) ? 1.0f : 0.0f;
}

// Convert light view position to projected texture coordinates
float2 getProjectiveCoords(float4 lightViewPosition)
{
    float2 projTex = lightViewPosition.xy / lightViewPosition.w;
    projTex *= float2(0.5, -0.5);
    projTex += float2(0.5f, 0.5f);
    return projTex;
}

float4 main(InputType input) : SV_TARGET
{
    float shadowMapBias = 0.0005f;  // Adjust bias as needed
    float4 textureColor = shaderTexture.Sample(diffuseSampler, input.tex);
    float4 color = float4(0.f, 0.f, 0.f, 1.f);

    // Projective coordinates for each light
    float2 projTexCoord1 = getProjectiveCoords(input.lightViewPos1);
    float2 projTexCoord2 = getProjectiveCoords(input.lightViewPos2);

    // Determine shadow factors for each light
    float shadowFactor1 = hasDepthData(projTexCoord1) ? isInShadow(depthMapTexture1, projTexCoord1, input.lightViewPos1, shadowMapBias) : 1.0f;
    float shadowFactor2 = hasDepthData(projTexCoord2) ? isInShadow(depthMapTexture2, projTexCoord2, input.lightViewPos2, shadowMapBias) : 1.0f;

    // Combine shadows (average of both)
    float shadowFactor = (shadowFactor1 + shadowFactor2) * 0.5f;

    // Calculate lighting contributions from both lights
    float4 lightColor1 = calculateLighting(-direction1, input.normal, diffuse);
    float4 lightColor2 = calculateLighting(-direction2, input.normal, diffuse2);

    // Combine lighting with shadows and ambient light
    color = saturate((lightColor1 + lightColor2) * shadowFactor + ambient);

    return saturate(color) * textureColor;
}

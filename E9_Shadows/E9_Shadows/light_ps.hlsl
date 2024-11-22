Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
    float4 diffuseColour;
    float3 lightDirection;
    float padding;
    
    float4 diffuseColour2;
    float3 light2position;
    float specularPower;
    float4 specularColour;
    
    float4 ambientColour;
    
    float constantAtt;
    float linearAtt;
    float quadraticAtt;
    float padding2;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 worldPos : TEXCOORD1;
    float3 viewVector : TEXCOORD2;
};

float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    float4 colour = saturate(diffuse * intensity);
    return colour;
}

float4 calcSpecular(float3 lightDirection, float3 normal, float3 viewVector, float4
specularColour, float specularPower)
{
    // blinn-phong specular calculation
    float3 halfway = normalize(lightDirection + viewVector);
    float specularIntensity = pow(max(dot(normal, halfway), 0.0), specularPower);
    return saturate(specularColour * specularIntensity);
}

float4 calculatePointLight(float3 normal, float3 pixelPos, float4 diffuseColour)
{
    float3 lightDir = light2position - pixelPos;
    float distance = length(-lightDir);
    lightDir = normalize(lightDir);

    float diffuseIntensity = saturate(dot(normal, lightDir));
    float attenuation = 1.0f / (constantAtt + linearAtt * distance + quadraticAtt * distance * distance);
    float4 pointDiffuse = diffuseColour2 * diffuseIntensity * attenuation;
    
    return pointDiffuse;
}

float4 main(InputType input) : SV_TARGET
{
    float4 textureColour = texture0.Sample(sampler0, input.tex);
    float4 finalLightColour;
    
    float4 light1Colour = calculateLighting(-lightDirection, input.normal, diffuseColour);
    
    float4 light2Colour = calculatePointLight(input.normal, input.worldPos.xyz, diffuseColour2);
    
    finalLightColour = light1Colour + light2Colour + ambientColour;
    
    return saturate(finalLightColour * textureColour);
}


#version 330 core

vec3 godrays(
    float density,
    float weight,
    float decay,
    float exposure,
    int numSamples,
    sampler2D occlusionTexture,
    vec4 screenSpaceLightPos,
    vec2 uv
) 
{
    vec3 fragColor = vec3(0.0, 0.0, 0.0);


    // 判断光源深度是否在一个合适的范围内
    if (screenSpaceLightPos.w>0) 
    {
        vec2 deltaTextCoord = vec2(uv - screenSpaceLightPos.xy);
        vec2 textCoo = uv;
        deltaTextCoord *= (1.0 / float(numSamples)) * density;
        float illuminationDecay = 1.0;

        for (int i = 0; i < numSamples; i++) 
        {
            textCoo -= deltaTextCoord;
            vec3 samp = texture(occlusionTexture, textCoo).xyz;
            samp *= illuminationDecay * weight;
            fragColor += samp;
            illuminationDecay *= decay;
        }

        fragColor *= exposure;
    }

    return fragColor;
}

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;

uniform sampler2D SampleBase;
uniform sampler2D SampleBloom;
uniform sampler2D SampleSSAO;
uniform vec4 BloomParam;
uniform vec4 LightScreenPos_Dir;

const float uDensity = 1.0;
const float uWeight = 0.01;
const float uDecay = 1.0;
const float uExposure = 1.0;
const int uNumSamples = 100;

void main()
{
	vec2 uv = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	
	vec4 baseColor = texture(SampleBase, uv);
	vec4 bloomColor = texture(SampleBloom, uv);
	vec4 ssaoColor = texture(SampleSSAO, uv);
	
	vec4 lastcolor = baseColor*(ssaoColor) + bloomColor*(BloomParam.r+1.0);

	lastcolor.xyz += godrays(
		uDensity,
		uWeight,
		uDecay,
		uExposure,
		uNumSamples,
		SampleBase,
		LightScreenPos_Dir,
		uv
    ) * BloomParam.g * LightScreenPos_Dir.w;
	
	pixelColor = lastcolor;
}
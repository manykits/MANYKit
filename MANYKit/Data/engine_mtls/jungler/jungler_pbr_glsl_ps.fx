#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

const float PI = 3.14159265359;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec4 vertexTCoord2;
in vec4 vertexTCoord3;
in vec4 vertexTCoord4;

uniform vec4 UVOffset;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;
uniform vec4 ShineEmissive;
uniform vec4 ShineAmbient;
uniform vec4 CameraWorldPosition;
uniform vec4 LightWorldDVector_Dir;
uniform vec4 LightAmbient_Dir;
uniform vec4 LightDiffuse_Dir;
uniform vec4 LightGroup[6];

uniform sampler2D SampleBase;
uniform sampler2D SampleColor;
uniform sampler2D SampleNormal;
uniform sampler2D SampleMetallic;
uniform sampler2D SampleRoughness;
uniform sampler2D SampleAO;
uniform sampler2D SampleShadowDepth;

highp float GetDepth(vec4 texCord, float i, float j)
{
	highp vec4 newUV = texCord + vec4(texCord.w*i*0.001, texCord.w*j*0.001, 0.0, 0.0);
	highp float depthColor = textureProj(SampleShadowDepth, newUV).r;
	//float depthColor = texture(SampleShadowDepth, vec2((texCord.x-0.001)/texCord.w, (texCord.y-0.001)/texCord.w)).r;
	return depthColor;
}

vec3 getNormalFromMap(sampler2D sn, vec2 texCord, vec3 wp, vec3 wn)
{
    vec3 tangentNormal = texture(sn, texCord).xyz * 2.0 - 1.0;

    vec3 Q1  = dFdx(wp);
    vec3 Q2  = dFdy(wp);
    vec2 st1 = dFdx(texCord);
    vec2 st2 = dFdy(texCord);

    vec3 N = normalize(wn);
    vec3 T = normalize(Q1*st2.t - Q2*st1.t);
    vec3 B = normalize(cross(N, T));
    mat3 TBN = mat3(T, B, N);

    return normalize(TBN * tangentNormal);
}

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a = roughness*roughness;
    float a2 = a*a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 doLight(vec3 N, vec3 V, vec3 F0, vec3 albedo, float metallic, float roughness, vec3 lightDir, vec3 lightColor, float attenuation, float power)
{
	// dir light
	vec3 L = normalize(lightDir);
	vec3 H = normalize(V + L);
	vec3 radiance = lightColor*attenuation*power;

	float NDF = DistributionGGX(N, H, roughness);   
	float G   = GeometrySmith(N, V, L, roughness);      
	vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);

	vec3 numerator    = NDF * G * F; 
	float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001; // + 0.0001 to prevent divide by zero
	vec3 specular = numerator / denominator;

	vec3 kS = F;
	vec3 kD = vec3(1.0) - kS;
	kD *= 1.0 - metallic;
	float NdotL = max(dot(N, L), 0.0);   
	vec3 val = (kD * albedo / PI + specular) * radiance * NdotL;

	return val;
}

void main()
{
	vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	texCoord.xy += UVOffset.xy;
	texCoord *= UVOffset.zw;
	vec4 baseColor = texture(SampleBase, texCoord);
	vec4 lastColor = texture(SampleColor, texCoord);

	if (baseColor.a < 0.25)
	{
		discard;
	}
	else
	{
		float metallic  = texture(SampleMetallic, texCoord).r;
		float roughness = texture(SampleRoughness, texCoord).r;
		float ao        = texture(SampleAO, texCoord).r;
		vec3 albedo = pow(lastColor.rgb, vec3(2.2));
		vec3 WorldPos = vertexTCoord3.xyz;
		vec3 WorldNormal = vec3(vertexTCoord4.x, vertexTCoord4.y,vertexTCoord4.z);
		vec3 N = getNormalFromMap(SampleNormal, texCoord, WorldPos, WorldNormal);
		vec3 V = normalize(CameraWorldPosition.xyz - WorldPos);

		vec3 F0 = vec3(0.04); 
		F0 = mix(F0, albedo, metallic);

		vec3 Lo = vec3(0.0);
		Lo += doLight(N, V, F0, albedo, metallic, roughness, -LightWorldDVector_Dir.xyz, LightDiffuse_Dir.rgb, 1.0, 1.0);

		for (int i=0; i<3; i++)
		{
			vec3 lp = LightGroup[i*3].xyz;
			float lr = LightGroup[i*3].w;
			vec3 lc = LightGroup[i*3+1].rgb;
			vec3 lightDir = normalize(lp - WorldPos);
			float distance = length(lp - WorldPos);
        	float attenuation = 1.0 / (distance * distance);
			Lo += doLight(N, V, F0, albedo, metallic, roughness, lightDir, lc, attenuation, 1.0);
		}		

		vec3 ambient = ShineAmbient.r * LightAmbient_Dir.rbg * albedo * ao;		
		vec3 colorpbr = ambient + Lo;

		// HDR tonemapping
		colorpbr = colorpbr / (colorpbr + vec3(1.0));
		// gamma correct
		colorpbr = pow(colorpbr, vec3(1.0/2.2)); 

		lastColor.xyz = colorpbr;
		
		// shadow map depth
		vec4 texCord = vertexTCoord2;
		float shadowDepth = 0.0;
		if (texCord.x<=0.01 ||texCord.x>=0.99||texCord.y<=0.01 ||texCord.y>=0.99)
		{
			shadowDepth = 1.0;
		}
		else
		{
			float depth = texCord.z/texCord.w;
			float depthP = GetDepth(texCord, 0.0, 0.0);
			shadowDepth = depthP > depth ? 1.0:0.0;

			depthP = GetDepth(texCord, -1.0, -1.0);
			shadowDepth += depthP > depth ? 1.0:0.0;

			depthP = GetDepth(texCord, -1.0, 0.0);	
			shadowDepth += depthP > depth ? 1.0:0.0;
			
			shadowDepth *= 0.3333;

			mediump float sc = ShineEmissive.r + LightAmbient_Dir.r*ShineAmbient.r;
			shadowDepth	= clamp(shadowDepth, sc, 1.0);
		}
		lastColor.rgb *= shadowDepth;
	
		lastColor.rgb = mix(FogColorHeight.rgb, lastColor.rgb, vertexTCoord1.x);
		lastColor.rgb = mix(FogColorDist.rgb, lastColor.rgb, vertexTCoord1.y);
		
		float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
		vec3 color = vec3(luminosity, luminosity, luminosity);
		if (0.0==FogColorHeight.w)
		{
			color = lastColor.rgb;
		}
		else if (1.0==FogColorHeight.w)
		{
			color = vec3(lastColor.r+0.5, lastColor.g, lastColor.b);
		}
		else if (2.0==FogColorHeight.w)	
		{
			color = vec3(lastColor.r, lastColor.g+0.5, lastColor.b);
		}
		else if (3.0==FogColorHeight.w)	
		{
			color = vec3(lastColor.r, lastColor.g, lastColor.b+0.5);
		}
		else if (4.0==FogColorHeight.w)	
		{
			float lv = mix(0.8, 1.0, luminosity);
			color = vec3(lv, lv, lv) * ShineEmissive.rgb;
		}

		lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);		

		float brightness = dot(lastColor.rgb, vec3(0.2126, 0.7152, 0.0722));		
		if (brightness > 1.0)
			pixelColor1 = lastColor;
		else	
			pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);
	
		pixelColor = lastColor;	
	}
}
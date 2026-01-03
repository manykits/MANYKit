#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

const float PI = 3.14159265359;

in vec4 vertexColor;
in vec4 vertexTCoord0;
in vec4 vertexTCoord1;
in vec4 vertexTCoord2;
in vec4 vertexTCoord3;
in vec4 vertexTCoord4;
in vec4 vertexTCoord5;
in vec4 vertexTCoord6;
in vec4 vertexTCoord7;

uniform vec4 UVScale01;
uniform vec4 UVScale23;
uniform vec4 UVScale4;

uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;

uniform vec4 CameraWorldPosition;
uniform vec4 LightWorldDVector_Dir;

uniform vec4 ShineEmissive;
uniform vec4 ShineAmbient;
uniform vec4 ShineDiffuse;
uniform vec4 ShineSpecular;

uniform vec4 LightAmbient_Dir;
uniform vec4 LightDiffuse_Dir;
uniform vec4 LightSpecular_Dir;
uniform vec4 LightGroup[9];

uniform sampler2D SampleAlpha;
uniform sampler2D Sample0;
uniform sampler2D Sample1;
uniform sampler2D Sample2;
uniform sampler2D Sample3;
uniform sampler2D Sample4;
uniform sampler2D Sample0Normal;
uniform sampler2D Sample1Normal;
uniform sampler2D Sample2Normal;
uniform sampler2D Sample3Normal;
uniform sampler2D Sample4Normal;
uniform sampler2D Sample0Roughness;
uniform sampler2D Sample1Roughness;
uniform sampler2D Sample2Roughness;
uniform sampler2D Sample3Roughness;

uniform sampler2D SampleShadowDepth;

vec3 DoLight_Point_Diffuse(vec3 lightToVertexDir, vec3 lightWorldPos, float lightRange, vec3 lightColor, vec3 shineDiffuse, vec3 vertexWorldPos, vec3 vertexWorldNormal)
{
	float dist = distance(lightWorldPos, vertexWorldPos);
	return lightColor * shineDiffuse * max(0.0, dot(vertexWorldNormal, lightToVertexDir)) * max(0.0, (1.0 - dist / lightRange) );
}
highp float GetDepth(vec4 texCord, float i, float j)
{
	highp vec4 newUV = texCord + vec4(texCord.w*i*0.001, texCord.w*j*0.001, 0.0, 0.0);
	highp float depthColor = textureProj(SampleShadowDepth, newUV).r;
				
	return depthColor;
}
vec3 getNormalFromMap(vec3 tangentNormal, vec2 texCord, vec3 wp, vec3 wn)
{
    vec3 Q1  = dFdx(wp);
    vec3 Q2  = dFdy(wp);
    vec2 st1 = dFdx(texCord);
    vec2 st2 = dFdy(texCord);

    vec3 N = normalize(wn);
    vec3 T = normalize(Q1*st2.t - Q2*st1.t);
    vec3 B = -normalize(cross(N, T));
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
	vec2 texCoord = vertexTCoord0.xy;
	texCoord.y = 1.0 - vertexTCoord0.y;
	
	vec2 texCoord1 = vertexTCoord1.xy;
	texCoord1.y = 1.0 - vertexTCoord1.y;
	
	vec4 colorAlpha = texture(SampleAlpha, vertexTCoord1.xy);
    vec4 color0 = texture(Sample0, texCoord.xy*UVScale01.xy);
   	vec4 color1 = texture(Sample1, texCoord1.xy*UVScale01.zw);
    vec4 color2 = texture(Sample2, texCoord1.xy*UVScale23.xy);
    vec4 color3 = texture(Sample3, texCoord1.xy*UVScale23.zw);
    vec4 color4 = texture(Sample4, texCoord1.xy*UVScale4.xy);
	
	vec4 lastColor = mix(color0 ,color1, colorAlpha.x);
    lastColor = mix(lastColor ,color2, colorAlpha.y);
    lastColor = mix(lastColor ,color3, colorAlpha.z);
    lastColor = mix(lastColor ,color4, colorAlpha.w);
	
	vec4 color0Normal = texture(Sample0Normal, texCoord.xy*UVScale01.xy);
   	vec4 color1Normal = texture(Sample1Normal, texCoord1.xy*UVScale01.zw);
    vec4 color2Normal = texture(Sample2Normal, texCoord1.xy*UVScale23.xy);
    vec4 color3Normal = texture(Sample3Normal, texCoord1.xy*UVScale23.zw);
    vec4 color4Normal = texture(Sample4Normal, texCoord1.xy*UVScale4.xy);	
	vec4 lastNormal = mix(color0Normal ,color1Normal, colorAlpha.x);
    lastNormal = mix(lastNormal ,color2Normal, colorAlpha.y);
    lastNormal = mix(lastNormal ,color3Normal, colorAlpha.z);
    lastNormal = mix(lastNormal ,color4Normal, colorAlpha.w);
	
	vec4 color0Roughness = texture(Sample0Roughness, texCoord.xy*UVScale01.xy);
   	vec4 color1Roughness = texture(Sample1Roughness, texCoord1.xy*UVScale01.zw);
    vec4 color2Roughness = texture(Sample2Roughness, texCoord1.xy*UVScale23.xy);
    vec4 color3Roughness = texture(Sample3Roughness, texCoord1.xy*UVScale23.zw);
    //vec4 color4Roughness = texture(Sample4Roughness, texCoord1.xy*UVScale4.xy);	
	vec4 lastRoughness = mix(color0Roughness ,color1Roughness, colorAlpha.x);
    lastRoughness = mix(lastRoughness ,color2Roughness, colorAlpha.y);
    lastRoughness = mix(lastRoughness ,color3Roughness, colorAlpha.z);
    //lastRoughness = mix(lastRoughness ,color4Roughness, colorAlpha.w);

    float metallic = 0.0;
	float roughness = lastRoughness.r;
	float ao = 1.0;
	
	vec3 albedo = pow(lastColor.rgb, vec3(2.2));	

	vec3 WorldPos = vec3(vertexTCoord5.w, vertexTCoord6.w, vertexTCoord7.w);
	vec3 WorldNormal = vec3(vertexTCoord0.w, vertexTCoord1.w, vertexTCoord2.w);
	vec3 N = normalize(getNormalFromMap(lastNormal.xyz, texCoord*UVScale01.xy, WorldPos, WorldNormal).xyz);
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
	vec4 texCord = vertexTCoord4;	
	highp float shadowDepth = GetDepth(texCord, 0.0, 0.0);
	shadowDepth += GetDepth(texCord, -1.0, -1.0);
	shadowDepth += GetDepth(texCord, -1.0, 0.0);	
	shadowDepth *= 0.3333;
	if (texCord.x<=0.01 ||texCord.x>=0.99||texCord.y<=0.01 ||texCord.y>=0.99)
	{
		shadowDepth = 1.0;
	}	
	mediump float sc = ShineEmissive.r + LightAmbient_Dir.r*ShineAmbient.r;
	shadowDepth	= clamp(shadowDepth, sc, 1.0);
	
	lastColor.rgb *= shadowDepth;	

	// fog
	vec2 vTCoord1 = vec2(vertexTCoord0.z, vertexTCoord1.z);
	if (4.0==FogColorHeight.w)
	{
		lastColor.rgb = mix(vec3(1.0, 1.0, 1.0), lastColor.rgb, 0.5);
		vTCoord1.x = 1.0 - (1.0-vTCoord1.x) * 0.2;
		vTCoord1.y = 1.0 - (1.0-vTCoord1.y) * 0.2;
	}
	
	lastColor.rgb = mix(FogColorHeight.rgb, lastColor.rgb, vTCoord1.x);
	lastColor.rgb = mix(FogColorDist.rgb, lastColor.rgb, vTCoord1.y);
	
	float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
	vec3 color = vec3(luminosity, luminosity, luminosity);
	if (0.0==FogColorHeight.w)
	{
		color = vec3(luminosity, luminosity, luminosity);
	}
	else if (1.0==FogColorHeight.w)
	{
		color = vec3(1.0, luminosity, luminosity);
	}
	else if (2.0==FogColorHeight.w)	
	{
		color = vec3(luminosity*0.2, 1.0, luminosity*0.2);	
	}
	else if (3.0==FogColorHeight.w)	
	{
		color = vec3(luminosity, luminosity, 1.0);	
	}

	lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);		
	
	float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
	if (brightness > 1.0)
		pixelColor1 = lastColor;
	else	
		pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);
	
	pixelColor = lastColor;
}
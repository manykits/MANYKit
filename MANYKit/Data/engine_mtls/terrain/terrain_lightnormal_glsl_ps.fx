#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

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

	vec3 worldPosition = vec3(vertexTCoord5.w, vertexTCoord6.w, vertexTCoord7.w);
	vec3 worldNormal = vec3(vertexTCoord0.w, vertexTCoord1.w, vertexTCoord2.w);
	vec3 tangentNormal = lastNormal.xyz * 2.0 - 1.0;
	
	vec3 lightdir_t = vertexTCoord2.xyz;
	vec3 viewvector_t = vertexTCoord3.xyz;
	
	vec3 ltov0 = vertexTCoord5.xyz;
	vec3 ltov1 = vertexTCoord6.xyz;
	vec3 ltov2 = vertexTCoord7.xyz;

	// light
	vec4 lighting = vec4(0.0, 0.0, 0.0, 0.0);
	vec3 halfVector = normalize((viewvector_t - lightdir_t)/2.0);
	float dotH = max(dot(tangentNormal, halfVector), 0.0);
	float dotN = max(dot(tangentNormal, lightdir_t), 0.0);
	lighting.rgb = ShineEmissive.rgb + LightAmbient_Dir.a *(ShineAmbient.rgb * LightAmbient_Dir.rgb +
		ShineDiffuse.rgb * LightDiffuse_Dir.rgb * dotN +
		ShineSpecular.rgb * LightSpecular_Dir.rgb * max(pow(dotH, ShineSpecular.a*LightSpecular_Dir.a), 0.0));
	lighting.a = ShineEmissive.a;
	
	lighting.rgb += DoLight_Point_Diffuse(ltov0, LightGroup[0].xyz, LightGroup[0].w, LightGroup[1].rgb, ShineDiffuse.rgb, worldPosition.xyz, tangentNormal.xyz);
	lighting.rgb += DoLight_Point_Diffuse(ltov1, LightGroup[2].xyz, LightGroup[2].w, LightGroup[3].rgb, ShineDiffuse.rgb, worldPosition.xyz, tangentNormal.xyz);
	lighting.rgb += DoLight_Point_Diffuse(ltov2, LightGroup[4].xyz, LightGroup[4].w, LightGroup[5].rgb, ShineDiffuse.rgb, worldPosition.xyz, tangentNormal.xyz);
	vec4 lightColor = lighting;
	
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
	lightColor.rgb *= shadowDepth;	

	// lighting
	lastColor.rgb *= lightColor.rgb;

	// fog
	vec2 vTCoord1 = vec2(vertexTCoord0.z, vertexTCoord1.z);
	if (4.0==FogColorHeight.w)
	{
		vTCoord1.x = 1.0 - (1.0-vTCoord1.x) * 0.2;
		vTCoord1.y = 1.0 - (1.0-vTCoord1.y) * 0.2;
	}
	
	lastColor.rgb = mix(FogColorHeight.rgb, lastColor.rgb, vTCoord1.x);
	lastColor.rgb = mix(FogColorDist.rgb, lastColor.rgb, vTCoord1.y);
	
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
		color = lightColor.rgb;
	}

	lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);		
	
	float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
	if (brightness > 1.0)
		pixelColor1 = lastColor;
	else	
		pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);
	
	pixelColor = lastColor;
}

#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec4 vertexTCoord0;
in vec4 vertexTCoord1;
in vec4 vertexTCoord2;
in vec4 vertexTCoord3;
in vec4 vertexTCoord4;
in vec4 vertexTCoord5;
in vec4 vertexTCoord6;
in vec4 vertexTCoord7;
uniform vec4 UVOffset;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;
uniform vec4 ShineEmissive;
uniform vec4 ShineAmbient;
uniform vec4 ShineDiffuse;
uniform vec4 ShineSpecular;
uniform vec4 LightAmbient_Dir;
uniform vec4 LightDiffuse_Dir;
uniform vec4 LightSpecular_Dir;
uniform vec4 LightGroup[6];

uniform sampler2D SampleBase;
uniform sampler2D SampleNormal;
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
vec3 getNormalFromMap(sampler2D sn, vec2 texCord, vec3 wp, vec3 wn)
{
    vec3 tangentNormal = texture(sn, texCord).xyz * 2.0 - 1.0;

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

void main()
{
	vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	texCoord.xy += UVOffset.xy;
	vec4 lastColor = texture(SampleBase, texCoord*UVOffset.zw);
	
	if (lastColor.a < 0.25)
	{
		discard;
	}
	else
	{
		vec3 worldPosition = vec3(vertexTCoord5.w, vertexTCoord6.w, vertexTCoord7.w);
		vec3 worldNormal0 = vec3(vertexTCoord0.w, vertexTCoord1.w, vertexTCoord2.w);
		vec3 normalMap = normalize(getNormalFromMap(SampleNormal, texCoord*UVOffset.zw, worldPosition, worldNormal0).xyz);

		vec3 worldNormal = normalMap;	
		vec3 lightdir_t = vertexTCoord2.xyz;
		vec3 viewvector_t = vertexTCoord3.xyz;
		
		vec3 p0 = vertexTCoord5.xyz;
		vec3 p1 = vertexTCoord6.xyz;
		vec3 p2 = vertexTCoord7.xyz;
		
		// light
		vec4 lighting = vec4(0.0, 0.0, 0.0, 0.0);
		vec3 halfVector = normalize((viewvector_t - lightdir_t)/2.0);
		float dotH = max(dot(worldNormal, halfVector), 0.0);
		float dotN = max(dot(worldNormal, lightdir_t), 0.0);
		lighting.rgb = ShineEmissive.rgb + LightAmbient_Dir.a *(ShineAmbient.rgb * LightAmbient_Dir.rgb +
			ShineDiffuse.rgb * LightDiffuse_Dir.rgb * dotN +
			ShineSpecular.rgb * LightSpecular_Dir.rgb * max(pow(dotH, ShineSpecular.a*LightSpecular_Dir.a), 0.0));
		lighting.a = ShineEmissive.a;
		
		lighting.rgb += DoLight_Point_Diffuse(p0, LightGroup[0].xyz, LightGroup[0].w, LightGroup[1].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		lighting.rgb += DoLight_Point_Diffuse(p1, LightGroup[2].xyz, LightGroup[2].w, LightGroup[3].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		lighting.rgb += DoLight_Point_Diffuse(p2, LightGroup[4].xyz, LightGroup[4].w, LightGroup[5].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
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
		vec2 vTCoord1 = vertexTCoord1.xy;
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
			color = vec3(luminosity, 1.0, luminosity);	
		}
		else if (3.0==FogColorHeight.w)	
		{
			color = vec3(luminosity, luminosity, 1.0);	
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
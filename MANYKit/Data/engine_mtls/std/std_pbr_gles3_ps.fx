#version 300 es 

precision mediump float;

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec3 vertexTCoord2;
in vec3 vertexTCoord3;
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

highp float GetDepth(mediump vec4 texCord, mediump float i, mediump float j)
{
	highp vec4 newUV = texCord + vec4(texCord.w*i*0.001, texCord.w*j*0.001, 0.0, 0.0);
	highp float depthColor = textureProj(SampleShadowDepth, newUV).r;
				
	return depthColor;
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
		vec3 normalMap = normalize(texture(SampleNormal, texCoord*UVOffset.zw).xyz * 2.0 - 1.0);
	
		vec3 worldNormal = normalMap;	
		vec3 lightdir_t = vertexTCoord2;
		vec3 viewvector_t = vertexTCoord3;
		
		vec3 p0 = vertexTCoord5.xyz;
		vec3 p1 = vertexTCoord6.xyz;
		vec3 p2 = vertexTCoord7.xyz;
		vec3 worldPosition = vec3(vertexTCoord5.w, vertexTCoord6.w, vertexTCoord7.w);
		
		vec4 lighting;
		vec3 halfVector = normalize((viewvector_t - lightdir_t)/2.0);
		float dotH = max(dot(worldNormal, halfVector), 0.0);
		float dotN = max(dot(worldNormal, lightdir_t), 0.0);
		lighting.rgb = ShineEmissive.rgb + LightAmbient_Dir.a *(ShineAmbient.rgb * LightAmbient_Dir.rgb + ShineDiffuse.rgb * LightDiffuse_Dir.rgb * dotN +
			ShineSpecular.rgb * LightSpecular_Dir.rgb * pow(dotH, ShineSpecular.a*LightSpecular_Dir.a));
		lighting.a = ShineEmissive.a;
		
		lighting.rgb += DoLight_Point_Diffuse(p0, LightGroup[0].xyz, LightGroup[0].w, LightGroup[1].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		lighting.rgb += DoLight_Point_Diffuse(p1, LightGroup[2].xyz, LightGroup[2].w, LightGroup[3].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		lighting.rgb += DoLight_Point_Diffuse(p2, LightGroup[4].xyz, LightGroup[4].w, LightGroup[5].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		
		// light
		vec4 lightColor = lighting;
		
		// shadow map depth
		vec4 texCord = vertexTCoord4;
		highp float shadowDepth = GetDepth(texCord, 0.0, 0.0);
		shadowDepth += GetDepth(texCord, -1.0, -1.0);
		shadowDepth += GetDepth(texCord, -1.0, 0.0);	
		//shadowDepth += GetDepth(texCord, -1.0, 1.0);
		//shadowDepth += GetDepth(texCord, 0.0, -1.0);
		//shadowDepth += GetDepth(texCord, 0.0, 1.0);
		//shadowDepth += GetDepth(texCord, 1.0, -1.0);
		//shadowDepth += GetDepth(texCord, 1.0, 0.0);
		//shadowDepth += GetDepth(texCord, 1.0, 1.0);	
		//shadowDepth *= 0.1111;
		shadowDepth *= 0.3333;
		if (texCord.x<=0.01 ||texCord.x>=0.99||texCord.y<=0.01 ||texCord.y>=0.99)
		{
			shadowDepth = 1.0;
		}	
		shadowDepth	= clamp(shadowDepth, 0.4, 1.0);
		lightColor.rgb *= shadowDepth;		
	
		lastColor.rgb *= lightColor.rgb;
	
		lastColor.rgb = mix(FogColorHeight.rgb, lastColor.rgb, vertexTCoord1.x);
		lastColor.rgb = mix(FogColorDist.rgb, lastColor.rgb, vertexTCoord1.y);
		
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
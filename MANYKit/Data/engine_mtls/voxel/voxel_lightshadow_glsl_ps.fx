#version 330 core

uniform sampler2D SampleBase;
uniform sampler2D SampleCorner;
uniform sampler2D SampleShadowDepth;

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec4 vertexTCoord2;
in vec4 vertexTCoord3;

in vec2 vertexTCoord4;

uniform vec4 UVOffset;
uniform vec4 ShineEmissive;
uniform vec4 ShineAmbient;
uniform vec4 LightAmbient_Dir;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;

float GetDepth(vec4 texCord, float i, float j)
{
	vec4 newUV = texCord + vec4(texCord.w*i*0.001, texCord.w*j*0.001, 0.0, 0.0);
	float depthColor = textureProj(SampleShadowDepth, newUV).r;
	//float depthColor = texture(SampleShadowDepth, vec2((texCord.x-0.001)/texCord.w, (texCord.y-0.001)/texCord.w)).r;
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
		vec4 cornerColor = texture(SampleCorner, vertexTCoord4);
		lastColor += (cornerColor*0.25); 

		mediump vec4 texCord = vertexTCoord2;
			
		mediump float shadowDepth = 0.0;
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
	
		lastColor *= vertexTCoord3;	
		
		vec2 vTCoord1 = vertexTCoord1.xy;
		if (4.0==FogColorHeight.w)
		{
			vTCoord1.x = 1.0 - (1.0-vTCoord1.x) * 0.2;
			vTCoord1.y = 1.0 - (1.0-vTCoord1.y) * 0.2;
		}
		
		lastColor.rgb = lastColor.rgb * vTCoord1.x + FogColorHeight.rgb * (1.0 - vTCoord1.x);
		lastColor.rgb = lastColor.rgb * vTCoord1.y + FogColorDist.rgb * (1.0 - vTCoord1.y);

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
			color = vertexTCoord3.rgb;
		}
		
		lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);	
		
		float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
		if (brightness > 1.0)
			pixelColor1 = lastColor;
		else	
			pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);
		
		pixelColor = lastColor;
	}
}
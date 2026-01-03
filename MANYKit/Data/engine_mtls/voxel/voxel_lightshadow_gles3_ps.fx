#version 300 es 

precision mediump float;

uniform sampler2D SampleBase;
uniform sampler2D SampleShadowDepth;

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in highp vec4 vertexTCoord2;
in vec4 vertexTCoord3;

uniform vec4 UVOffset;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;

highp float GetDepth(mediump vec4 texCord, mediump float i, mediump float j)
{
	highp vec4 newUV = texCord + vec4(texCord.w*i*0.001, texCord.w*j*0.001, 0.0, 0.0);
	highp float depthColor = textureProj(SampleShadowDepth, newUV).r;
	//highp float depthColor = texture(SampleShadowDepth, vec2((texCord.x-0.001)/texCord.w, (texCord.y-0.001)/texCord.w)).r;
	return depthColor;
}

void main()
{
	mediump vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	texCoord.xy += UVOffset.xy;
	mediump vec4 lastColor = texture(SampleBase, texCoord*UVOffset.zw);
	
	if (lastColor.a < 0.25)
	{
		discard;
	}
	else
	{
		mediump vec2 vTCoord1 = vertexTCoord1;
		if (4.0==FogColorHeight.w)
		{
			lastColor.rgb = mix(vec3(1.0, 1.0, 1.0), lastColor.rgb, 0.5);
			vTCoord1.x = 1.0 - (1.0-vTCoord1.x) * 0.2;
			vTCoord1.y = 1.0 - (1.0-vTCoord1.y) * 0.2;
		}
	
		mediump vec4 texCord = vertexTCoord2;
		mediump float shadowDepth = 0.0;
		
		if (texCord.x<=0.01 ||texCord.x>=0.99||texCord.y<=0.01 ||texCord.y>=0.99)
		{
			shadowDepth = 1.0;
		}
		else
		{
			highp float depth = texCord.z/texCord.w;
			highp float depthP = GetDepth(texCord, 0.0, 0.0);
			shadowDepth = depthP > depth ? 1.0:0.0;

			depthP = GetDepth(texCord, -1.0, -1.0);
			shadowDepth += depthP > depth ? 1.0:0.0;

			depthP = GetDepth(texCord, -1.0, 0.0);	
			shadowDepth += depthP > depth ? 1.0:0.0;

			shadowDepth *= 0.3333;
		}
		shadowDepth	= clamp(shadowDepth, 0.4, 1.0);
		lastColor.rgb *= shadowDepth;
	
		lastColor *= vertexTCoord3;	
		
		lastColor.rgb = lastColor.rgb * vTCoord1.x + FogColorHeight.rgb * (1.0 - vTCoord1.x);
		lastColor.rgb = lastColor.rgb * vTCoord1.y + FogColorDist.rgb * (1.0 - vTCoord1.y);
		
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
		
		float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
		if (brightness > 1.0)
			pixelColor1 = lastColor;
		else	
			pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);
		
		pixelColor = lastColor;
	}
}
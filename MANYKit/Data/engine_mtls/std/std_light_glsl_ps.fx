#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec4 vertexTCoord2;
uniform vec4 UVOffset;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;
uniform sampler2D SampleBase;

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
		lastColor *= vertexTCoord2;	
	
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
			color = vertexTCoord2.rgb;
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
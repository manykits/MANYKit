#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec4 vertexColor;
in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec2 vertexTCoord2;
uniform vec4 UVScale01;
uniform vec4 UVScale23;
uniform vec4 UVScale4;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;

uniform sampler2D SamplerWalk;

void main()
{
    // texture	
	vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	
	vec4 lastColor = texture(SamplerWalk, texCoord);

	if (4==FogColorHeight.w)
	{
		lastColor.rgb = mix(vec3(1.0, 1.0, 1.0), lastColor.rgb, 0.5);
	}
	
	lastColor *= vertexColor;
	
	// fog
	lastColor.rgb = mix(FogColorHeight.rgb, lastColor.rgb, vertexTCoord2.y);
	lastColor.rgb = mix(FogColorDist.rgb, lastColor.rgb, vertexTCoord2.x);
	
	float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
	vec3 color = vec3(luminosity, luminosity, luminosity);
	if (0==FogColorHeight.w)
	{
		color = vec3(luminosity, luminosity, luminosity);
	}
	else if (1==FogColorHeight.w)
	{
		color = vec3(1.0, luminosity, luminosity);
	}
	else if (2==FogColorHeight.w)	
	{
		color = vec3(luminosity, 1.0, luminosity);	
	}
	else if (3==FogColorHeight.w)	
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
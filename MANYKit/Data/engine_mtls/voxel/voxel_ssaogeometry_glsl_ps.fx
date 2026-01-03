#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;
layout (location = 2) out vec4 pixelColor2;

in vec3 fragPos;
in vec2 vertexTCoord0;
in vec3 normal;

uniform sampler2D SampleBase;

void main()
{
	vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	vec4 lastColor = texture(SampleBase, texCoord);
	
	if (lastColor.a < 0.1)
	{
		discard;
	}
	else
	{
		pixelColor = vec4(fragPos, 1.0);
	    pixelColor1 = vec4(normalize(normal), 1.0);
	    pixelColor2 = vec4(1.0, 0.6, 0.6, 1.0);
	}
}

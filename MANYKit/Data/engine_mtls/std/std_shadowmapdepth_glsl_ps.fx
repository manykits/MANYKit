#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;

uniform sampler2D SampleBase;

void main()
{
	vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	vec4 texColor = texture(SampleBase, texCoord);
	
	if (texColor.a < 0.25)
	{
		discard;
	}
	else
	{
		pixelColor = vec4(vertexTCoord1.x, vertexTCoord1.x, vertexTCoord1.x, 1.0);
	}
}
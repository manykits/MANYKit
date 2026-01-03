#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;
uniform vec4 ShineEmissive;
uniform sampler2D SampleBase;

void main()
{
	vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	pixelColor = texture(SampleBase, texCoord)*ShineEmissive;
}
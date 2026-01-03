#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

uniform vec4 UVParam;
uniform vec4 ShineEmissive;
in vec2 vertexTCoord0;
in vec4 vertexTCoord1;
uniform sampler2D SampleBase;
void main()
{
	vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;

	vec4 color = texture(SampleBase, texCoord);
	pixelColor = color*vertexTCoord1*ShineEmissive;
	pixelColor1 = vec4(0,0,0,0);
}
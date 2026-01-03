#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec3 vertexTCoord0;
uniform sampler3D SampleBase;

void main()
{
	pixelColor = texture(SampleBase, vertexTCoord0);
}
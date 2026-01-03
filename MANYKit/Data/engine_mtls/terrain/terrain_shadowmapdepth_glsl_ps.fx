#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;
void main()
{
	pixelColor = vec4(vertexTCoord0.r, vertexTCoord0.r,vertexTCoord0.r, 1.0);
}
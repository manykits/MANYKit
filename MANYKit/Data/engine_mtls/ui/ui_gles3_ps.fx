#version 300 es

precision mediump float;

layout (location = 0) out vec4 pixelColor;

uniform vec4 UVParam;
uniform vec4 ShineEmissive;
in vec2 vertexTCoord0;
in vec4 vertexTCoord1;
uniform sampler2D SampleBase;
void main()
{
	mediump vec2 texCord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y)*UVParam.xy;
	mediump vec4 color = texture(SampleBase, texCord);
	pixelColor = color*vertexTCoord1*ShineEmissive;
}
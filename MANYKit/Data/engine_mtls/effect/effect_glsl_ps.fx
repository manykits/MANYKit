#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec4 vertexColor0;
in vec2 vertexTCoord0;
uniform sampler2D Sample0;

void main()
{
	vec2 tecCord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	vec4 color = texture2D(Sample0, tecCord);
	
	vec4 lastColor = color*vertexColor0;
	
	float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
	if (brightness > 1.0)
		pixelColor1 = lastColor;
	else	
		pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);	
	
	pixelColor = lastColor;
}
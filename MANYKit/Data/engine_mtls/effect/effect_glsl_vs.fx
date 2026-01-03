#version 330 core

uniform mat4 PVWMatrix;
in vec3 modelPosition;
in vec4 modelColor0;
in vec2 modelTCoord0;
out vec4 vertexColor0;
out vec2 vertexTCoord0;

void main()
{
	gl_Position = PVWMatrix	* vec4(modelPosition, 1.0);
	vertexColor0 = modelColor0;
	vertexTCoord0 = modelTCoord0;
}
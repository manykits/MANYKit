#version 330 core

uniform mat4 PVWMatrix;
in vec3 modelPosition;
in vec2 modelTCoord0;
out vec2 vertexTCoord0;

void main()
{
	gl_Position = PVWMatrix*vec4(modelPosition, 1.0);
	vertexTCoord0 = modelTCoord0;
}
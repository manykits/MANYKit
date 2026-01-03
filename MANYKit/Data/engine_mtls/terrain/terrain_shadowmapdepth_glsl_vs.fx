#version 330 core

in vec3 modelPosition;
out vec2 vertexTCoord0;
uniform mat4 PVWMatrix;

void main()
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	vertexTCoord0.r = gl_Position.r;
}
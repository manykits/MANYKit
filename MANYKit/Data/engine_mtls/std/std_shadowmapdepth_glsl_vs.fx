#version 330 core

float linearizedepth(float depth, vec4 cameraparam)
{
    float z = (depth - cameraparam.x)/(cameraparam.y - cameraparam.x);
	return z;
}

in vec3 modelPosition;
in vec2 modelTCoord0;
out vec2 vertexTCoord0;
out vec2 vertexTCoord1;
uniform mat4 PVWMatrix;
uniform mat4 VWMatrix;
uniform vec4 ProjectorParam;

void main()
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	vec4 viewPos = VWMatrix * vec4(modelPosition, 1.0);
	
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1.x = linearizedepth(viewPos.z, ProjectorParam);
}
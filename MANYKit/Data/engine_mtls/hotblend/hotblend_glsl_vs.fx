#version 330 core

uniform mat4 PVWMatrix;
in vec3 modelPosition;
in vec4 modelColor0;
in vec2 modelTCoord0;
in vec2 modelTCoord1;
in vec2 modelTCoord2;
in vec2 modelTCoord3;
out vec2 vertexTCoord0;
out vec2 vertexTCoord1;
out vec2 vertexTCoord2;
out vec2 vertexTCoord3; // origin
out vec4 vertexTCoord4;
void main()
{
	gl_Position = PVWMatrix*vec4(modelPosition, 1.0);
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = modelTCoord1;
	vertexTCoord2 = modelTCoord2;
	vertexTCoord3 = modelTCoord3;
	vertexTCoord4 = modelColor0;
}
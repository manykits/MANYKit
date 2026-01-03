#version 300 es

uniform mat4 PVWMatrix;
in vec3 modelPosition;
in vec4 modelColor0;
in vec2 modelTCoord0;
out vec2 vertexTCoord0;
out vec4 vertexTCoord1;
void main()
{
	gl_Position = PVWMatrix*vec4(modelPosition, 1.0);
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = modelColor0;
}
#version 330 core

in vec3 modelPosition;
in vec3 modelNormal;
in vec2 modelTCoord0;

out vec3 fragPos;
out vec2 vertexTCoord0;
out vec3 normal;    

uniform mat4 PVWMatrix;
uniform mat4 VWMatrix;

void main() 
{
    // Pos
    gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	
	// viewPos
	vec4 viewPos = VWMatrix * vec4(modelPosition, 1.0);
	fragPos = viewPos.xyz;

    // Tex Coord
    vertexTCoord0 = modelTCoord0;
	
	// normal
	mat3 normalMatrix = transpose(inverse(mat3(VWMatrix)));
	normal = mat3(normalMatrix) * modelNormal;   
}
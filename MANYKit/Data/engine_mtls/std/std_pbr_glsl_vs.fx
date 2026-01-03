#version 330 core

in vec3 modelPosition;
in vec3 modelNormal;
in vec2 modelTCoord0;

out vec2 vertexTCoord0;
out vec2 vertexTCoord1;
out vec4 vertexTCoord2;
out vec4 vertexTCoord3;
out vec4 vertexTCoord4;

uniform mat4 PVWMatrix;
uniform mat4 WMatrix;
uniform mat4 ProjectPVBSMatrix_Dir;
uniform vec4 CameraWorldPosition;
uniform vec4 FogParam;

void main() 
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	
	vertexTCoord0 = modelTCoord0;
	
	vec4 worldPosition = (WMatrix * vec4(modelPosition, 1.0));	
	vertexTCoord3 = worldPosition;
	vec3 worldNormal = mat3(WMatrix) * modelNormal;   
	
	vertexTCoord4.xyz = worldNormal;
	vertexTCoord4.w = 1.0;

	// shadow
	vertexTCoord2 = ProjectPVBSMatrix_Dir * vec4(modelPosition, 1.0);

	// fog
	float dist = distance(CameraWorldPosition.xyz, worldPosition.xyz);
	
	float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0.0, 1.0);
	float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0.0, 1.0);

	if (FogParam.y < FogParam.x)
		fogValueHeight = 1.0;
	if (FogParam.w < FogParam.z)
		fogValueDist = 1.0;	
	
	vertexTCoord1.x = fogValueHeight;
	vertexTCoord1.y = fogValueDist;
}
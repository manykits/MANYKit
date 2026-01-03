#version 330 core

in vec3 modelPosition;
in vec3 modelNormal;
in vec3 modelColor0;
in vec2 modelTCoord0;
in vec2 modelTCoord1;
in vec2 modelTCoord2;
in vec2 modelTCoord3;
in vec2 modelTCoord4;
in vec2 modelTCoord5;

out vec2 vertexTCoord0;
out vec2 vertexTCoord1;
out vec2 vertexTCoord2;
out vec2 vertexTCoord3;
out vec2 vertexTCoord4;
out vec2 vertexTCoord5;
out vec4 vertexTCoord6;
out vec4 vertexTCoord7;
out vec4 vertexTCoord8;
out vec2 vertexTCoord9;

uniform mat4 PVWMatrix;
uniform mat4 WMatrix;
uniform mat4 ProjectPVBSMatrix_Dir;
uniform vec4 CameraWorldPosition;
uniform vec4 FogParam;

void main() 
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = modelTCoord1;
	vertexTCoord2 = modelTCoord2;
	vertexTCoord3 = modelTCoord3;
	vertexTCoord4 = modelTCoord4;
	
	vec4 worldPosition = (WMatrix * vec4(modelPosition, 1.0));	
	vertexTCoord7 = worldPosition;
	vec3 worldNormal = mat3(WMatrix) * modelNormal;   
	
	vertexTCoord8.xyz = worldNormal;
	vertexTCoord8.w = 1.0;

	// shadow
	vertexTCoord6 = ProjectPVBSMatrix_Dir * vec4(modelPosition, 1.0);

	// fog
	float dist = distance(CameraWorldPosition.xyz, worldPosition.xyz);
	
	float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0.0, 1.0);
	float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0.0, 1.0);
	
	vertexTCoord5.x = fogValueHeight;
	vertexTCoord5.y = fogValueDist;
	
	vertexTCoord9 = modelTCoord5;
}
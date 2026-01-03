#version 330 core

in vec3 modelPosition;
in vec3 modelNormal;
in vec2 modelTCoord0;
in vec3 tangent;
in vec3 binormal;

out vec4 vertexTCoord0;
out vec4 vertexTCoord1;
out vec4 vertexTCoord2;
out vec4 vertexTCoord3;
out vec4 vertexTCoord4;
out vec4 vertexTCoord5;
out vec4 vertexTCoord6;
out vec4 vertexTCoord7;

uniform mat4 PVWMatrix;
uniform mat4 WMatrix;
uniform mat4 ProjectPVBSMatrix_Dir;
uniform vec4 LightModelDVector_Dir;
uniform vec4 CameraWorldPosition;
uniform vec4 CameraModelPosition;
uniform vec4 LightModelGroup[6];
uniform vec4 FogParam;

void main() 
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	
	vertexTCoord0.xy = modelTCoord0;
	
	vec3 worldPosition = (WMatrix * vec4(modelPosition, 1.0)).xyz;	
	vec4 col0 = WMatrix[0]; vec4 col1 = WMatrix[1]; vec4 col2 = WMatrix[2]; 
	mat3 worldMat = mat3(col0.xyz, col1.xyz, col2.xyz);
	vec3 worldNormal = normalize(worldMat * modelNormal);
	
	vertexTCoord0.w = worldNormal.x;
	vertexTCoord1.w = worldNormal.y;
	vertexTCoord2.w = worldNormal.z;

	mat3 mat = mat3(tangent, binormal, modelNormal);
	
	// view
	vec3 cdir = normalize(CameraModelPosition.xyz - modelPosition.xyz);
	vertexTCoord3.xyz = mat * cdir;

	// shadow
	vertexTCoord4 = ProjectPVBSMatrix_Dir * vec4(modelPosition, 1.0);
	
	vec3 ldir = -normalize(LightModelDVector_Dir.xyz);
	vertexTCoord2.xyz = mat * ldir;
	
	vec3 lv0 = LightModelGroup[0].xyz + LightModelGroup[1].xyz*0.0000001 - modelPosition;
	vec3 lv1 = LightModelGroup[2].xyz + LightModelGroup[3].xyz*0.0000001 - modelPosition;
	vec3 lv2 = LightModelGroup[4].xyz + LightModelGroup[5].xyz*0.0000001 - modelPosition;
	vertexTCoord5.xyz = mat * lv0;
	vertexTCoord6.xyz = mat * lv1;
	vertexTCoord7.xyz = mat * lv2;

	vertexTCoord5.w = worldPosition.x;
	vertexTCoord6.w = worldPosition.y;
	vertexTCoord7.w = worldPosition.z;
	
	// fog
	float dist = distance(CameraWorldPosition.xyz, worldPosition.xyz);
	float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0.0, 1.0);
	float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0.0, 1.0);
	
	vertexTCoord1.x = fogValueHeight;
	vertexTCoord1.y = fogValueDist;
}
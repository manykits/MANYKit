#version 330 core

in vec3 modelPosition;
out vec3 vertexTCoord0;
out vec2 vertexTCoord1;
out vec4 vertexTCoord2;
uniform mat4 PVWMatrix;
uniform mat4 WMatrix;
uniform vec4 CameraWorldPosition;
uniform vec4 FogParam;

void main() 
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	
	vec4 worldPosition = WMatrix * vec4(modelPosition, 1.0);
	vertexTCoord0 = worldPosition.xyz - CameraWorldPosition.xyz;
	
	float dist = sqrt((CameraWorldPosition.x - worldPosition.x)*(CameraWorldPosition.x - worldPosition.x) + (CameraWorldPosition.y - worldPosition.y)*(CameraWorldPosition.y - worldPosition.y) + (CameraWorldPosition.z - worldPosition.z)*(CameraWorldPosition.z - worldPosition.z));
	
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

	worldPosition.xyz -= CameraWorldPosition.xyz;
	vertexTCoord2 = worldPosition;
}
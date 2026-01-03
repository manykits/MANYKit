attribute mediump vec3 modelPosition;
varying mediump vec3 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
uniform mat4 PVWMatrix;
uniform mat4 WMatrix;
uniform vec4 CameraWorldPosition;
uniform vec4 FogParam;

void main() 
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	mediump vec4 worldPosition = WMatrix * vec4(modelPosition, 1.0);
	vertexTCoord0 = worldPosition.xyz - CameraWorldPosition.xyz;
	
	mediump float dist = sqrt((CameraWorldPosition.x - worldPosition.x)*(CameraWorldPosition.x - worldPosition.x) + (CameraWorldPosition.y - worldPosition.y)*(CameraWorldPosition.y - worldPosition.y) + (CameraWorldPosition.z - worldPosition.z)*(CameraWorldPosition.z - worldPosition.z));
	
	mediump float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0.0, 1.0);
	mediump float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0.0, 1.0);
	
	vertexTCoord1.x = fogValueHeight;
	vertexTCoord1.y = fogValueDist;
}
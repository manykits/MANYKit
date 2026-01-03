#version 300 es

in vec3 modelPosition;
in vec3 modelNormal;
in vec2 modelTCoord0;
in vec3 tangent;
in vec3 binormal;

out vec2 vertexTCoord0;
out vec2 vertexTCoord1;
out vec3 vertexTCoord2;
out vec3 vertexTCoord3;
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
	
	vertexTCoord0 = modelTCoord0;
	
	vec3 worldPosition = (WMatrix * vec4(modelPosition, 1.0)).xyz;	
	vec4 col0 = WMatrix[0]; vec4 col1 = WMatrix[1]; vec4 col2 = WMatrix[2]; 
	mat3 worldMat = mat3(col0.xyz, col1.xyz, col2.xyz);
	vec3 worldNormal = normalize(worldMat * modelNormal);
	
	// shadow
	vertexTCoord4 = ProjectPVBSMatrix_Dir * vec4(modelPosition, 1.0);
	
	vec3 t = tangent;
	vec3 b = binormal;
	vec3 n = modelNormal;
	
	vec3 ldir = -normalize(LightModelDVector_Dir.xyz);
	vec3 ldir1;
	ldir1.x = dot(t, ldir);
	ldir1.y = dot(b, ldir);
	ldir1.z = dot(n, ldir);
	vertexTCoord2 = ldir1;
	
	vec3 p0 = LightModelGroup[0].xyz + LightModelGroup[1].xyz*0.00001;
	vec3 p1 = LightModelGroup[2].xyz + LightModelGroup[3].xyz*0.00001;
	vec3 p2 = LightModelGroup[4].xyz + LightModelGroup[5].xyz*0.00001;
	
	vec3 lv0 = p0 - modelPosition;
	vec3 lv1 = p1 - modelPosition;
	vec3 lv2 = p2 - modelPosition;
	
	vec3 lv00;
	vec3 lv10;
	vec3 lv20;
	lv00.x = dot(t, lv0);
	lv00.y = dot(b, lv0);
	lv00.z = dot(n, lv0);
	
	lv10.x = dot(t, lv1);
	lv10.y = dot(b, lv1);
	lv10.z = dot(n, lv1);
	
	lv20.x = dot(t, lv2);
	lv20.y = dot(b, lv2);
	lv20.z = dot(n, lv2);
	
	vertexTCoord5.xyz = lv00;
	vertexTCoord6.xyz = lv10;
	vertexTCoord7.xyz = lv20;
	vertexTCoord5.w = worldPosition.x;
	vertexTCoord6.w = worldPosition.y;
	vertexTCoord7.w = worldPosition.z;
	
	// view
	vec3 cdir = normalize(CameraModelPosition.xyz - modelPosition.xyz);	
	vec3 cdir1;
	cdir1.x = dot(t, cdir);
	cdir1.y = dot(b, cdir);
	cdir1.z = dot(n, cdir);	
	vertexTCoord3 = cdir1;
	
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
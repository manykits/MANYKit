#version 330 core

in vec3 modelPosition;
in vec3 modelNormal;
in vec2 modelTCoord0;
in vec4 modelTCoord1;
in vec4 modelTCoord2;
out vec4 vertexColor;
out vec2 vertexTCoord0;
out vec2 vertexTCoord1;
uniform mat4 PVWMatrix;
uniform vec4 BoneTM[117];

void main()
{
	int i0 = int(modelTCoord1[0])*3;
	int i1 = int(modelTCoord1[1])*3;
	int i2 = int(modelTCoord1[2])*3;
	int i3 = int(modelTCoord1[3])*3;
	
	vec4 inputPos = vec4(modelPosition.x, modelPosition.y, modelPosition.z, 1.0);
	vec3 worldPosition = vec3(0, 0, 0);
	worldPosition += vec3(dot(inputPos, BoneTM[i0]), dot(inputPos, BoneTM[i0 + 1]), dot(inputPos, BoneTM[i0 + 2])) * modelTCoord2[0];
	worldPosition += vec3(dot(inputPos, BoneTM[i1]), dot(inputPos, BoneTM[i1 + 1]), dot(inputPos, BoneTM[i1 + 2])) * modelTCoord2[1];
	worldPosition += vec3(dot(inputPos, BoneTM[i2]), dot(inputPos, BoneTM[i2 + 1]), dot(inputPos, BoneTM[i2 + 2])) * modelTCoord2[2];
	worldPosition += vec3(dot(inputPos, BoneTM[i3]), dot(inputPos, BoneTM[i3 + 1]), dot(inputPos, BoneTM[i3 + 2])) * modelTCoord2[3];
	vec3 worldNormal = vec3(0, 0, 0);
	worldNormal += vec3(dot(modelNormal, BoneTM[i0].xyz), dot(modelNormal, BoneTM[i0 + 1].xyz), dot(modelNormal, BoneTM[i0 + 2].xyz)) * modelTCoord2[0];
	worldNormal += vec3(dot(modelNormal, BoneTM[i1].xyz), dot(modelNormal, BoneTM[i1 + 1].xyz), dot(modelNormal, BoneTM[i1 + 2].xyz)) * modelTCoord2[1];
	worldNormal += vec3(dot(modelNormal, BoneTM[i2].xyz), dot(modelNormal, BoneTM[i2 + 1].xyz), dot(modelNormal, BoneTM[i2 + 2].xyz)) * modelTCoord2[2];	
	worldNormal += vec3(dot(modelNormal, BoneTM[i3].xyz), dot(modelNormal, BoneTM[i3 + 1].xyz), dot(modelNormal, BoneTM[i3 + 2].xyz)) * modelTCoord2[3];
	worldNormal = normalize(worldNormal);
	
	gl_Position = PVWMatrix * vec4(worldPosition, 1.0);
	
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1.r = gl_Position.z/gl_Position.w;
}
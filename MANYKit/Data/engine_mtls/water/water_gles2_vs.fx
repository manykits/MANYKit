attribute mediump vec3 modelPosition;
attribute mediump vec3 modelNormal;
attribute mediump vec2 modelTCoord0;
varying mediump vec2 vertexTCoord0;
varying mediump vec4 vertexTCoord1;
varying mediump vec4 vertexTCoord2;
varying mediump vec4 vertexTCoord3;
varying mediump vec4 vertexTCoord4;
uniform mat4 PVWMatrix;
uniform mat4 WMatrix;
uniform vec4 CameraWorldPosition;

void main()
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);

	vec4 worldPosition = WMatrix * vec4(modelPosition, 1.0);
	vec3 worldNormal = mat3(WMatrix) * modelNormal;

	vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = worldPosition;
	vertexTCoord2.xyz = worldNormal;
	vertexTCoord3.xyz = CameraWorldPosition.xyz - worldPosition.xyz;

	mat4 remappingMat = mat4(
                        0.5, 0.0, 0.0, 0.0,
                        0.0, 0.5, 0.0, 0.0,
                        0.0, 0.0, 0.5, 0.0, 
                        0.5, 0.5, 0.5, 1.0 
                        );
	vertexTCoord4 = remappingMat * PVWMatrix * vec4(modelPosition, 1.0);
}
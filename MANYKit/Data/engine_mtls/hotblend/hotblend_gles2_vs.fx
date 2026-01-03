uniform mat4 PVWMatrix;
attribute mediump vec3 modelPosition;
attribute mediump vec4 modelColor0;
attribute mediump vec2 modelTCoord0;
attribute mediump vec2 modelTCoord1;
attribute mediump vec2 modelTCoord2;
attribute mediump vec2 modelTCoord3;
varying mediump vec2 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
varying mediump vec2 vertexTCoord2;
varying mediump vec2 vertexTCoord3; // origin
varying mediump vec4 vertexTCoord4;
void main()
{
	gl_Position = PVWMatrix*vec4(modelPosition, 1.0);
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = modelTCoord1;
	vertexTCoord2 = modelTCoord2;
	vertexTCoord3 = modelTCoord3;
	vertexTCoord4 = modelColor0;
}
attribute mediump vec3 modelPosition;
attribute mediump vec2 modelTCoord0;
varying mediump vec2 vertexTCoord0;
varying highp vec2 vertexTCoord1;
uniform mat4 PVWMatrix;
uniform mat4 VWMatrix;
uniform vec4 ProjectorParam;

mediump float linearizedepth(mediump float depth, mediump vec4 cameraparam)
{
    mediump float z = (depth - cameraparam.x)/(cameraparam.y - cameraparam.x);
	return z;
}

void main()
{
	gl_Position = PVWMatrix * vec4(modelPosition, 1.0);
	mediump vec4 viewPos = VWMatrix * vec4(modelPosition, 1.0);
	
	vertexTCoord0 = modelTCoord0;
	vertexTCoord1.x = linearizedepth(viewPos.z, ProjectorParam);
}
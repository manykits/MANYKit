uniform mediump vec4 UVParam;
uniform mediump vec4 ShineEmissive;
varying mediump vec2 vertexTCoord0;
varying mediump vec4 vertexTCoord1;
uniform sampler2D SampleBase;
void main()
{
	mediump vec2 texCord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y)*UVParam.xy;
	mediump vec4 color = texture2D(SampleBase, texCord);
	gl_FragColor = color*vertexTCoord1*ShineEmissive;
}
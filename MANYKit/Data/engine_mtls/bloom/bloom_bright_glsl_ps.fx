#version 330 core

in vec2 vertexTCoord0;

uniform mediump vec4 BrightParam;
uniform sampler2D SampleBase;

void main()
{
	vec2 texCord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	vec4 color = texture(SampleBase, texCord);
	
	color.rgb -= normalize(color.rgb) * BrightParam.r;
	
	color = max(color, 0.0);
	
	color.rgb = color.rgb * color.rgb;
	
	gl_FragColor = color;
}
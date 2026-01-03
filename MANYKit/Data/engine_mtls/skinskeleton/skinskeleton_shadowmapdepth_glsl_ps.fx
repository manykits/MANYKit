#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
uniform sampler2D SampleBase;
uniform mediump vec4 UVOffset;
void main()
{
	mediump vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	texCoord.xy += UVOffset.xy;
	mediump vec4 texColor = texture2D(SampleBase, texCoord);
	
	if (texColor.a < 0.25)
	{
		discard;
	}
	else
	{
		vec4 lastColor =  vec4(vertexTCoord1.r, vertexTCoord1.r,vertexTCoord1.r, 1.0);
		float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
		if (brightness > 1.0)
			pixelColor1 = lastColor;
		else	
			pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);
	
		pixelColor = lastColor;	
	}
}
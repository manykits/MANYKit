#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;

uniform vec4 TexSize;
uniform sampler2D SampleBase;

void main()
{
	vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	vec2 texelSize1 = 1.0 / TexSize.xy;
	
	//float result = texture(SampleBase, texCoord).r;
	
	float result = 0.0;
	for (int x = -2; x < 2; ++x) 
    {
        for (int y = -2; y < 2; ++y) 
        {
            vec2 offset = vec2(float(x), float(y)) * texelSize1.xy;
            result += texture(SampleBase, texCoord + offset).r;
        }
    }
	result = result / 16.0;
	
	pixelColor = vec4(result,result,result,1.0);
}
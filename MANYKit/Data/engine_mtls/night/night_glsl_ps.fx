#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;
in vec4 vertexTCoord1;
uniform vec4 UVParam;
uniform vec4 ShineEmissive;
uniform vec4 Control;
uniform sampler2D SampleBase;
void main()
{
	vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	vec2 texCoordTemp = texCoord;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;

    vec4 texColor = texture(SampleBase, texCoord);
	if (texCoord.x<0.0 || texCoord.x>1.0 ||texCoord.y<0.0 || texCoord.y>1.0)
	{
		pixelColor=vec4(0,0,0,1);
	}
	else
	{
		vec3 color = texColor.rgb;
		float luminosity = 0.299 * texColor.r + 0.587 * texColor.g + 0.114 * texColor.b;
		if (0.0==Control.w)
		{
			color = vec3(luminosity, luminosity, luminosity);
		}
		else if (1.0==Control.w)
		{
			color = vec3(color.r+0.5, color.g, color.b);
		}
		else if (2.0==Control.w)	
		{
			color = vec3(color.r, color.g+0.5, color.b);
		}
		else if (3.0==Control.w)	
		{
			color = vec3(color.r, color.g, color.b+0.5);
		}

		vec3 texColorConstrast = texColor.rgb + ( (texColor.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 1.0;
		vec3 texColorConstrast1 = color.rgb + ( (color.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 2.0;
			
		texColor.rgb = mix(texColorConstrast.rgb, texColorConstrast1.rgb, 1.0-Control.y);

		pixelColor = texColor*vertexTCoord1*ShineEmissive;
	}
}
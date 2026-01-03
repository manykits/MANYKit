#version 330 core

layout (location = 0) out vec4 pixelColor;

uniform sampler2D SampleBase;
uniform sampler2D SampleBase1;
uniform sampler2D SampleBase2;
uniform sampler2D SampleHotGray;

in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec2 vertexTCoord2;
in vec2 vertexTCoord3;
in vec4 vertexTCoord4;
uniform vec4 ImageBlend;
uniform vec4 ShineEmissive;
uniform vec4 Anchor;
uniform vec4 Control;
uniform vec4 Control1;
uniform vec4 Control2;
uniform vec4 UVParam;
void main()
{
	float xDiff = vertexTCoord0.x - vertexTCoord3.x;
	float yDiff = vertexTCoord0.y - vertexTCoord3.y;

	float clipx = step(Anchor.x - xDiff, vertexTCoord3.x) * step(vertexTCoord3.x, Anchor.y - xDiff);
	float xPerc =  clipx*(vertexTCoord3.x-Anchor.x + xDiff) / (Anchor.y-Anchor.x);

	float xDist = (Anchor.y-Anchor.x);
	float yDist = (Anchor.w-Anchor.z);

	float clipy = step(Anchor.z - yDiff, vertexTCoord3.y) * step(vertexTCoord3.y, Anchor.w - yDiff);
	float yPerc = clipy*(vertexTCoord3.y-Anchor.z + yDiff) / (Anchor.w-Anchor.z);

	vec2 texCoord = vertexTCoord0;
	vec2 texCoord1Temp = texCoord;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;
	
	vec2 texCoord1 = vertexTCoord1;
	vec2 texCoord1Temp1 = texCoord1;
    texCoord1.y = 1.0 - vertexTCoord1.y;
	texCoord1 *= UVParam.xy;
	texCoord1 += UVParam.zw;
	
	vec2 texCoord2 = vertexTCoord2;
	texCoord2.x = xPerc;
	texCoord2.y = 1.0 - yPerc;
	texCoord2 *= UVParam.xy;
	texCoord2 += UVParam.zw/vec2(xDist, yDist);

    vec4 texColor = texture(SampleBase, texCoord); // color
	vec3 texColorConstrast = texColor.rgb + ( (texColor.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 1.0;
	texColorConstrast.rgb *= Control.z;
	float luminosity = 0.299 * texColorConstrast.r + 0.587 * texColorConstrast.g + 0.114 * texColorConstrast.b;
	vec3 color = texColor.rgb;
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
	texColor.rgb = mix(texColorConstrast.rgb, color, 1.0-Control.y);
	
	vec4 texColor1 = texture(SampleBase1, texCoord1); // wei
	vec3 texColorConstrast1 = texColor1.rgb + ( (texColor1.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control1.x-0.5) * 1.0;
	texColorConstrast1.rgb *= Control1.z;
	float luminosity1 = 0.299 * texColorConstrast1.r + 0.587 * texColorConstrast1.g + 0.114 * texColorConstrast1.b;
	vec3 color1 = texColor1.rgb;
	if (0==Control1.w)
	{
		color1 = vec3(luminosity1, luminosity1, luminosity1);
	}
	else if (1.0==Control1.w)
	{
		color1 = vec3(color1.r+0.5, color1.g, color1.b);
	}
	else if (2.0==Control1.w)	
	{
		color1 = vec3(color1.r, color1.g+0.5, color1.b);
	}
	else if (3.0==Control1.w)	
	{
		color1 = vec3(color1.r, color1.g, color1.b+0.5);
	}
	texColor1.rgb = mix(texColorConstrast1.rgb, color1.rgb, 1.0-Control1.y);
	
	vec4 texColor2 = texture(SampleBase2, texCoord2); // hot
	vec3 texColorConstrast2 = texColor2.rgb + ( (texColor2.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control2.x-0.5) * 1.0;
	texColorConstrast2.rgb *= Control2.z;
	float luminosity2 = 0.299 * texColorConstrast2.r + 0.587 * texColorConstrast2.g + 0.114 * texColorConstrast2.b;
	vec3 color2 = texColor2.rgb;
	if (0.0==Control2.w)
	{
		color2 = vec3(luminosity2, luminosity2, luminosity2);
	}
	else if (1.0==Control2.w)
	{
		color2 = vec3(color2.r+0.5, color2.g, color2.b);
	}
	else if (2.0==Control2.w)	
	{
		color2 = vec3(color2.r, color2.g+0.5, color2.b);
	}
	else if (3.0==Control2.w)	
	{
		color2 = vec3(color2.r, color2.g, color2.b+0.5);
	}
	float tpval = 1.0;
	if (texCoord2.x<0.0 || texCoord2.x>1.0 || texCoord2.y<0.0 || texCoord2.y>1.0)
		tpval = 0.0;

	texColor2.rgb = mix(texColorConstrast2.rgb, color2.rgb, 1.0-Control2.y);
	
	vec4 texColorHotGray = texture(SampleHotGray, texCoord2); // hotgray

	float stp = step(ImageBlend.a, texColorHotGray.g);
	
	float clp = clipx*clipy*tpval;
	vec4 colorbind = (texColor*ImageBlend.x + texColor1*ImageBlend.y) + texColor2*stp*ImageBlend.z*clp;
	if (ImageBlend.z > 0.9)
		colorbind = (texColor*ImageBlend.x + texColor1*ImageBlend.y) * (1.0-stp*clp) + texColor2*stp*ImageBlend.z*clp;
	colorbind.a = 1.0;
	
	float just = (texCoord1Temp1.x-0.5)*(texCoord1Temp1.x-0.5) + (texCoord1Temp1.y-0.5)*(texCoord1Temp1.y-0.5);
	if (just>0.1 && just<0.18)
	{
		colorbind = mix(colorbind, vec4(0.0, 0.0, 0.0, 1.0), (just-0.1)/0.08);
	}
	else if (just>0.18)
	{
		colorbind = vec4(0.0, 0.0, 0.0, 1.0);
	}	
	
	pixelColor = colorbind*vertexTCoord4*ShineEmissive;
}
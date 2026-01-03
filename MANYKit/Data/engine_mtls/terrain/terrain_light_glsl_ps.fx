#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec4 vertexColor;
in vec2 vertexTCoord0;
in vec2 vertexTCoord1;
in vec2 vertexTCoord2;
uniform vec4 UVScale01;
uniform vec4 UVScale23;
uniform vec4 UVScale4;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;
uniform sampler2D SampleAlpha;
uniform sampler2D Sample0;
uniform sampler2D Sample1;
uniform sampler2D Sample2;
uniform sampler2D Sample3;
uniform sampler2D Sample4;

void main()
{
	vec2 texCoord = vertexTCoord0;
	texCoord.y = 1.0 - vertexTCoord0.y;
	
	vec2 texCoord1 = vertexTCoord1;
	texCoord1.y = 1.0 - vertexTCoord1.y;
	
	vec4 colorAlpha = texture(SampleAlpha, vertexTCoord1);
    vec4 color0 = texture(Sample0, texCoord*UVScale01.xy);
	float cl = color0.r+color0.g+color0.b;

		vec4 color1 = texture(Sample1, texCoord1*UVScale01.zw);
		vec4 color2 = texture(Sample2, texCoord1*UVScale23.xy);
		vec4 color3 = texture(Sample3, texCoord1*UVScale23.zw);
		vec4 color4 = texture(Sample4, texCoord1*UVScale4.xy);
		
		vec4 lastColor = mix(color0 ,color1, colorAlpha.x);
		lastColor = mix(lastColor ,color2, colorAlpha.y);
		lastColor = mix(lastColor ,color3, colorAlpha.z);
		lastColor = mix(lastColor ,color4, colorAlpha.w);
		
		vec2 vTCoord2 = vertexTCoord2;
		if (4.0==FogColorHeight.w)
		{
			vTCoord2.x = 1.0 - (1.0-vTCoord2.x) * 0.2;
			vTCoord2.y = 1.0 - (1.0-vTCoord2.y) * 0.2;
		}	
		
		lastColor *= vertexColor;	
		
		lastColor.rgb = lastColor.rgb * vertexTCoord2.x + FogColorHeight.rgb * (1.0 - vertexTCoord2.x);
		lastColor.rgb = lastColor.rgb * vertexTCoord2.y + FogColorDist.rgb * (1.0 - vertexTCoord2.y);
		
		float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
		vec3 color = vec3(luminosity, luminosity, luminosity);
		if (0.0==FogColorHeight.w)
		{
			color = lastColor.rgb;
		}
		else if (1.0==FogColorHeight.w)
		{
			color = vec3(lastColor.r+0.5, lastColor.g, lastColor.b);	
		}
		else if (2.0==FogColorHeight.w)	
		{
			color = vec3(lastColor.r, lastColor.g+0.5, lastColor.b);	
		}
		else if (3.0==FogColorHeight.w)	
		{
			color = vec3(lastColor.r, lastColor.g+0.5, lastColor.b+0.5);	
		}
		else if (4.0==FogColorHeight.w)	
		{
			color = vec3(luminosity, luminosity, luminosity);	
		}
		
		lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);		
		
		float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
		if (brightness > 1.0)
			pixelColor1 = lastColor;
		else	
			pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);

		pixelColor = lastColor;
}
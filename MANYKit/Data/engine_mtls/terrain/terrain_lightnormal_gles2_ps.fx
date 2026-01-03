varying mediump vec4 vertexColor;
varying mediump vec2 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
varying mediump vec2 vertexTCoord2;
uniform mediump vec4 UVScale01;
uniform mediump vec4 UVScale23;
uniform mediump vec4 UVScale4;
uniform mediump vec4 FogColorHeight;
uniform mediump vec4 FogColorDist;
uniform sampler2D SampleAlpha;
uniform sampler2D Sample0;
uniform sampler2D Sample1;
uniform sampler2D Sample2;
uniform sampler2D Sample3;
uniform sampler2D Sample4;

void main()
{
	mediump vec2 texCoord = vertexTCoord0;
	texCoord.y = 1.0 - vertexTCoord0.y;
	
	mediump vec2 texCoord1 = vertexTCoord1;
	texCoord1.y = 1.0 - vertexTCoord1.y;
	
	mediump vec4 colorAlpha = texture2D(SampleAlpha, vertexTCoord1);
    mediump vec4 color0 = texture2D(Sample0, texCoord*UVScale01.xy);
    mediump vec4 color1 = texture2D(Sample1, texCoord1*UVScale01.zw);
    mediump vec4 color2 = texture2D(Sample2, texCoord1*UVScale23.xy);
    mediump vec4 color3 = texture2D(Sample3, texCoord1*UVScale23.zw);
    mediump vec4 color4 = texture2D(Sample4, texCoord1*UVScale4.xy);
	
	mediump vec4 lastColor = mix(color0 ,color1, colorAlpha.x);
	lastColor = mix(lastColor ,color2, colorAlpha.y);
	lastColor = mix(lastColor ,color3, colorAlpha.z);
	lastColor = mix(lastColor ,color4, colorAlpha.w);
	
	mediump vec2 vTCoord2 = vertexTCoord2;
	if (4.0==FogColorHeight.w)
	{
		lastColor.rgb = mix(vec3(1.0, 1.0, 1.0), lastColor.rgb, 0.5);
		vTCoord2.x = 1.0 - (1.0-vTCoord2.x) * 0.2;
		vTCoord2.y = 1.0 - (1.0-vTCoord2.y) * 0.2;
	}	
	
	lastColor *= vertexColor;	
	
	lastColor.rgb = lastColor.rgb * vertexTCoord2.x + FogColorHeight.rgb * (1.0 - vertexTCoord2.x);
	lastColor.rgb = lastColor.rgb * vertexTCoord2.y + FogColorDist.rgb * (1.0 - vertexTCoord2.y);
	
	mediump float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
	mediump vec3 color = vec3(luminosity, luminosity, luminosity);
	if (0.0==FogColorHeight.w)
	{
		color = vec3(luminosity, luminosity, luminosity);
	}
	else if (1.0==FogColorHeight.w)
	{
		color = vec3(1.0, luminosity, luminosity);
	}
	else if (2.0==FogColorHeight.w)	
	{
		color = vec3(luminosity, 1.0, luminosity);	
	}
	else if (3.0==FogColorHeight.w)	
	{
		color = vec3(luminosity, luminosity, 1.0);	
	}
	
	lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);		
	
	mediump float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
	
	gl_FragColor = lastColor;
}
varying mediump vec4 vertexColor;
varying mediump vec2 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
varying mediump vec2 vertexTCoord2;
varying mediump vec4 vertexTCoord3;
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
uniform sampler2D SampleShadowDepth;

mediump vec4 LerpColor(mediump vec4 color0, mediump vec4 color1, mediump float alpha)
{
	return color0 * (1.0-alpha) + color1 * alpha;
}

highp float GetDepth(mediump vec4 texCord, mediump float i, mediump float j)
{
	mediump vec4 newUV = texCord + vec4(texCord.w*i*0.001, texCord.w*j*0.001, 0.0, 0.0);
	highp float depthColor = texture2DProj(SampleShadowDepth, newUV).r;
				
	return depthColor;
}

void main()
{
	mediump vec2 texCoord = vertexTCoord0;
	texCoord.y = 1.0 - vertexTCoord0.y;
	
	mediump vec2 texCoord1 = vertexTCoord1;
	texCoord1.y = 1.0 - vertexTCoord1.y;
	
	mediump vec4 colorAlpha = texture2D(SampleAlpha, vertexTCoord0);
    mediump vec4 color0 = texture2D(Sample0, texCoord*UVScale01.xy);
   	mediump vec4 color1 = texture2D(Sample1, texCoord1*UVScale01.zw);
    mediump vec4 color2 = texture2D(Sample2, texCoord1*UVScale23.xy);
    mediump vec4 color3 = texture2D(Sample3, texCoord1*UVScale23.zw);
    mediump vec4 color4 = texture2D(Sample4, texCoord1*UVScale4.xy);
	
	mediump vec4 lastColor = LerpColor(color0 ,color1, colorAlpha.r);
    lastColor = LerpColor(lastColor ,color2, colorAlpha.g);
    lastColor = LerpColor(lastColor ,color3, colorAlpha.b);
    lastColor = LerpColor(lastColor ,color4, colorAlpha.a);
	
	mediump vec2 vTCoord2 = vertexTCoord2;
	if (4.0==FogColorHeight.w)
	{
		lastColor.rgb = mix(vec3(1.0, 1.0, 1.0), lastColor.rgb, 0.5);
		vTCoord2.x = 1.0 - (1.0-vTCoord2.x) * 0.2;
		vTCoord2.y = 1.0 - (1.0-vTCoord2.y) * 0.2;
	}
	
	highp vec4 texCord = vertexTCoord3;
	highp float depth = (texCord.z/texCord.w)*0.5 + 0.5;
	
	highp float shadowDepth = GetDepth(texCord, 0.0, 0.0);
	shadowDepth += GetDepth(texCord, -1.0, -1.0);
	shadowDepth += GetDepth(texCord, -1.0, 0.0);	
	shadowDepth *= 0.3333;
	if (texCord.x<=0.01 ||texCord.x>=0.99||texCord.y<=0.01 ||texCord.y>=0.99)
	{
		shadowDepth = 1.0;
	}
	shadowDepth	= clamp(shadowDepth, 0.4, 1.0);
	lastColor.rgb *= shadowDepth;
	
	lastColor.rgb = lastColor.rgb * vTCoord2.x + FogColorHeight.rgb * (1.0 - vTCoord2.x);
	lastColor.rgb = lastColor.rgb * vTCoord2.y + FogColorDist.rgb * (1.0 - vTCoord2.y);
	
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
	
	gl_FragColor.rgb = lastColor.rgb;
	gl_FragColor.a = 1.0;
}
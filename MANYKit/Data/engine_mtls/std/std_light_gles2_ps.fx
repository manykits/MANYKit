varying mediump vec2 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
varying mediump vec4 vertexTCoord2;
uniform mediump vec4 UVOffset;
uniform mediump vec4 FogColorHeight;
uniform mediump vec4 FogColorDist;
uniform sampler2D SampleBase;

void main()
{
	mediump vec2 texCoord = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	texCoord.xy += UVOffset.xy;
	mediump vec4 lastColor = texture2D(SampleBase, texCoord*UVOffset.zw);
	
	if (lastColor.a < 0.25)
	{
		discard;
	}
	else
	{
		lastColor *= vertexTCoord2;	
	
		lastColor.rgb = lastColor.rgb * vertexTCoord1.x + FogColorHeight.rgb * (1.0 - vertexTCoord1.x);
		lastColor.rgb = lastColor.rgb * vertexTCoord1.y + FogColorDist.rgb * (1.0 - vertexTCoord1.y);
		
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
		
		gl_FragColor = lastColor;
	}
}
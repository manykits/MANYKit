uniform mediump vec4 UVParam;
uniform mediump vec4 ShineEmissive;
uniform mediump vec4 Control;
uniform sampler2D SampleBase;
varying mediump vec2 vertexTCoord0;
varying mediump vec4 vertexTCoord1;
void main()
{
	mediump vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;
	
	mediump vec4 texColor = texture2D(SampleBase, texCoord);	
	mediump vec3 texColorConstrast = texColor.rgb + ( (texColor.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 1.0;
	mediump vec3 color = texColor.rgb;
	mediump float luminosity = 0.299 * texColorConstrast.r + 0.587 * texColorConstrast.g + 0.114 * texColorConstrast.b;
	if (0.0==Control.w)
	{
		color = vec3(luminosity, luminosity, luminosity);
	}
	else if (1.0==Control.w)
	{
		color = vec3(1.0, luminosity, luminosity);
	}
	else if (2.0==Control.w)	
	{
		color = vec3(luminosity, 1.0, luminosity);	
	}
	else if (3.0==Control.w)	
	{
		color = vec3(luminosity, luminosity, 1.0);	
	}
		
	texColor.rgb = mix(texColorConstrast.rgb, color.rgb, 1.0-Control.y);
	
	gl_FragColor = texColor*vertexTCoord1*ShineEmissive;
}
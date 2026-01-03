varying mediump vec2 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
varying mediump vec2 vertexTCoord2;
varying mediump vec2 vertexTCoord3;
varying mediump vec4 vertexTCoord4;

uniform mediump vec4 ImageBlend;
uniform mediump vec4 ShineEmissive;
uniform mediump vec4 Anchor;
uniform mediump vec4 Control;
uniform mediump vec4 Control1;
uniform mediump vec4 Control2;
uniform mediump vec4 UVParam;

uniform sampler2D SampleBase;
uniform sampler2D SampleBase1;
uniform sampler2D SampleBase2;
uniform sampler2D SampleHotGray;

void main()
{
	mediump float xDiff = vertexTCoord0.x - vertexTCoord3.x;
	mediump float yDiff = vertexTCoord0.y - vertexTCoord3.y;

	mediump float clipx = step(Anchor.x - xDiff, vertexTCoord3.x) * step(vertexTCoord3.x, Anchor.y - xDiff);
	mediump float xPerc =  clipx*(vertexTCoord3.x-Anchor.x + xDiff) / (Anchor.y-Anchor.x);

	mediump float clipy = step(Anchor.z - yDiff, vertexTCoord3.y) * step(vertexTCoord3.y, Anchor.w - yDiff);
	mediump float yPerc = clipy*(vertexTCoord3.y-Anchor.z + yDiff) / (Anchor.w-Anchor.z);

	mediump vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;
	
	mediump vec2 texCoord1 = vertexTCoord1;
    texCoord1.y = 1.0 - vertexTCoord1.y;
	
	mediump vec2 texCoord2 = vertexTCoord2;
	texCoord2.x = xPerc;
	texCoord2.y = 1.0 - yPerc;

    mediump vec4 texColor = texture2D(SampleBase, texCoord); // color
	mediump vec3 texColorConstrast = texColor.rgb + ( (texColor.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 1.0;
	texColorConstrast.rgb *= Control.z;
	mediump float luminosity = 0.299 * texColorConstrast.r + 0.587 * texColorConstrast.g + 0.114 * texColorConstrast.b;
	mediump vec3 color = texColor.rgb;
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
	texColor.rgb = mix(texColorConstrast.rgb, color, 1.0-Control.y);
	
	mediump vec4 texColor1 = texture2D(SampleBase1, texCoord1); // wei
	mediump vec3 texColorConstrast1 = texColor1.rgb + ( (texColor1.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control1.x-0.5) * 1.0;
	texColorConstrast1.rgb *= Control1.z;
	mediump float luminosity1 = 0.299 * texColorConstrast1.r + 0.587 * texColorConstrast1.g + 0.114 * texColorConstrast1.b;
	mediump vec3 color1 = texColor1.rgb;
	if (0.0==Control1.w)
	{
		color1 = vec3(luminosity1, luminosity1, luminosity1);
	}
	else if (1.0==Control1.w)
	{
		color1 = vec3(1.0, luminosity1, luminosity1);
	}
	else if (2.0==Control1.w)	
	{
		color1 = vec3(luminosity1, 1.0, luminosity1);	
	}
	else if (3.0==Control1.w)	
	{
		color1 = vec3(luminosity1, luminosity1, 1.0);	
	}
	texColor1.rgb = mix(texColorConstrast1.rgb, color1.rgb, 1.0-Control1.y);
	
	mediump vec4 texColor2 = texture2D(SampleBase2, texCoord2); // hot
	mediump vec3 texColorConstrast2 = texColor2.rgb + ( (texColor2.rgb - vec3(0.5, 0.5, 0.5) ) / vec3(0.5, 0.5, 0.5) ) * (Control2.x-0.5) * 1.0;
	texColorConstrast2.rgb *= Control2.z;
	mediump float luminosity2 = 0.299 * texColorConstrast2.r + 0.587 * texColorConstrast2.g + 0.114 * texColorConstrast2.b;
	mediump vec3 color2 = texColor2.rgb;
	if (0.0==Control2.w)
	{
		color2 = vec3(luminosity2, luminosity2, luminosity2);
	}
	else if (1.0==Control2.w)
	{
		color2 = vec3(1.0, luminosity2, luminosity2);
	}
	else if (2.0==Control2.w)	
	{
		color2 = vec3(luminosity2, 1.0, luminosity2);	
	}
	else if (3.0==Control2.w)	
	{
		color2 = vec3(luminosity2, luminosity2, 1.0);	
	}
	texColor2.rgb = mix(texColorConstrast2.rgb, color2.rgb, 1.0-Control2.y);
	
	mediump vec4 texColorHotGray = texture2D(SampleHotGray, texCoord2); // hotgray

	mediump float stp = step(ImageBlend.a, texColorHotGray.g);
	
	mediump float clp = clipx*clipy;
	mediump vec4 colorbind = (texColor*ImageBlend.x + texColor1*ImageBlend.y) + texColor2*stp*ImageBlend.z*clp;
	if (ImageBlend.z > 0.9)
		colorbind = (texColor*ImageBlend.x + texColor1*ImageBlend.y) * (1.0-stp*clp) + texColor2*stp*ImageBlend.z*clp;
	colorbind.a = 1.0;
	
	gl_FragColor = colorbind*vertexTCoord4*ShineEmissive;
}
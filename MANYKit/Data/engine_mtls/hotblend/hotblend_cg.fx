// hotblend.fx

void v_hotblend
(
    in float3 modelPosition : POSITION,
	in float4 modelColor0 : COLOR,
    in float2 modelTCoord0 : TEXCOORD0,
	in float2 modelTCoord1 : TEXCOORD1,
	in float2 modelTCoord2 : TEXCOORD2,
	in float2 modelTCoord3 : TEXCOORD3,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	out float2 vertexTCoord1 : TEXCOORD1,
	out float2 vertexTCoord2 : TEXCOORD2,
	out float2 vertexTCoord3 : TEXCOORD3, // origin texcoord
	out float4 vertexTCoord4 : TEXCOORD4, // color
	uniform float4x4 PVWMatrix
)
{
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));
    vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = modelTCoord1;
	vertexTCoord2 = modelTCoord2;
	vertexTCoord3 = modelTCoord3;
	vertexTCoord4 = modelColor0;
}

sampler2D SampleBase;
sampler2D SampleBase1;
sampler2D SampleBase2;
sampler2D SampleHotGray;

void p_hotblend
(
    in float2 vertexTCoord0 : TEXCOORD0,
	in float2 vertexTCoord1 : TEXCOORD1,
	in float2 vertexTCoord2 : TEXCOORD2,
	in float2 vertexTCoord3 : TEXCOORD3,  // origin texcoord
	in float4 vertexTCoord4 : TEXCOORD4,
    out float4 pixelColor : COLOR,
	uniform float4 ImageBlend,
	uniform float4 ShineEmissive,
	uniform float4 Anchor,
	uniform float4 Control,
	uniform float4 Control1,
	uniform float4 Control2,
	uniform float4 UVParam
)
{
	float xDiff = vertexTCoord0.x - vertexTCoord3.x;
	float yDiff = vertexTCoord0.y - vertexTCoord3.y;

	float clipx = step(Anchor.x - xDiff, vertexTCoord3.x) * step(vertexTCoord3.x, Anchor.y - xDiff);
	float xPerc =  clipx*(vertexTCoord3.x-Anchor.x + xDiff) / (Anchor.y-Anchor.x);

	float clipy = step(Anchor.z - yDiff, vertexTCoord3.y) * step(vertexTCoord3.y, Anchor.w - yDiff);
	float yPerc = clipy*(vertexTCoord3.y-Anchor.z + yDiff) / (Anchor.w-Anchor.z);

	float2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;
	
	float2 texCoord1 = vertexTCoord1;
    texCoord1.y = 1.0 - vertexTCoord1.y;
	
	float2 texCoord2 = vertexTCoord2;
	texCoord2.x = xPerc;
	texCoord2.y = 1.0 - yPerc;

    float4 texColor = tex2D(SampleBase, texCoord); // color
	float3 texColorConstrast = texColor.rgb + ( (texColor.rgb - float3(0.5, 0.5, 0.5) ) / float3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 1.0;
	texColorConstrast.rgb *= Control.z;
	float luminosity = 0.299 * texColorConstrast.r + 0.587 * texColorConstrast.g + 0.114 * texColorConstrast.b;
	float3 color = texColor.rgb;
	if (0==Control.w)
	{
		color = float3(luminosity, luminosity, luminosity);
	}
	else if (1==Control.w)
	{
		color = float3(1.0, luminosity, luminosity);
	}
	else if (2==Control.w)	
	{
		color = float3(luminosity, 1.0, luminosity);	
	}
	else if (3==Control.w)	
	{
		color = float3(luminosity, luminosity, 1.0);	
	}
	texColor.rgb = lerp(texColorConstrast.rgb, color, 1.0-Control.y);
	
	float4 texColor1 = tex2D(SampleBase1, texCoord1); // wei
	float3 texColorConstrast1 = texColor1.rgb + ( (texColor1.rgb - float3(0.5, 0.5, 0.5) ) / float3(0.5, 0.5, 0.5) ) * (Control1.x-0.5) * 1.0;
	texColorConstrast1.rgb *= Control1.z;
	float luminosity1 = 0.299 * texColorConstrast1.r + 0.587 * texColorConstrast1.g + 0.114 * texColorConstrast1.b;
	float3 color1 = texColor1.rgb;
	if (0==Control1.w)
	{
		color1 = float3(luminosity1, luminosity1, luminosity1);
	}
	else if (1==Control1.w)
	{
		color1 = float3(1.0, luminosity1, luminosity1);
	}
	else if (2==Control1.w)	
	{
		color1 = float3(luminosity1, 1.0, luminosity1);	
	}
	else if (3==Control1.w)	
	{
		color1 = float3(luminosity1, luminosity1, 1.0);	
	}
	texColor1.rgb = lerp(texColorConstrast1.rgb, color1.rgb, 1.0-Control1.y);
	
	float4 texColor2 = tex2D(SampleBase2, texCoord2); // hot
	float3 texColorConstrast2 = texColor2.rgb + ( (texColor2.rgb - float3(0.5, 0.5, 0.5) ) / float3(0.5, 0.5, 0.5) ) * (Control2.x-0.5) * 1.0;
	texColorConstrast2.rgb *= Control2.z;
	float luminosity2 = 0.299 * texColorConstrast2.r + 0.587 * texColorConstrast2.g + 0.114 * texColorConstrast2.b;
	float3 color2 = texColor2.rgb;
	if (0==Control2.w)
	{
		color2 = float3(luminosity2, luminosity2, luminosity2);
	}
	else if (1==Control2.w)
	{
		color2 = float3(1.0, luminosity2, luminosity2);
	}
	else if (2==Control2.w)	
	{
		color2 = float3(luminosity2, 1.0, luminosity2);	
	}
	else if (3==Control2.w)	
	{
		color2 = float3(luminosity2, luminosity2, 1.0);	
	}
	texColor2.rgb = lerp(texColorConstrast2.rgb, color2.rgb, 1.0-Control2.y);
	
	float4 texColorHotGray = tex2D(SampleHotGray, texCoord2); // hotgray

	float stp = step(ImageBlend.a, texColorHotGray.g);
	
	float clp = clipx*clipy;
	float4 colorbind = (texColor*ImageBlend.x + texColor1*ImageBlend.y) + texColor2*stp*ImageBlend.z*clp;
	if (ImageBlend.z > 0.9)
		colorbind = (texColor*ImageBlend.x + texColor1*ImageBlend.y) * (1.0-stp*clp) + texColor2*stp*ImageBlend.z*clp;
	colorbind.a = 1.0;
	pixelColor = colorbind*vertexTCoord4*ShineEmissive;
}
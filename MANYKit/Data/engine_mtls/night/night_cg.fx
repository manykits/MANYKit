// night.fx

void v_night
(
    in float3 modelPosition : POSITION,
	in float4 modelColor0 : COLOR,
    in float2 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	out float4 vertexTCoord1 : TEXCOORD1,
	uniform float4x4 PVWMatrix
)
{
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));
    vertexTCoord0 = modelTCoord0;
	vertexTCoord1 = modelColor0;
}

sampler2D SampleBase;

void p_night
(
    in float2 vertexTCoord0 : TEXCOORD0,
	in float4 vertexTCoord1 : TEXCOORD1,
    out float4 pixelColor : COLOR,
	uniform float4 UVParam,
	uniform float4 ShineEmissive,
	uniform float4 Control
)
{
	float2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord *= UVParam.xy;
	texCoord += UVParam.zw;

    float4 texColor = tex2D(SampleBase, texCoord);
	float3 texColorConstrast = texColor.rgb + ( (texColor.rgb - float3(0.5, 0.5, 0.5) ) / float3(0.5, 0.5, 0.5) ) * (Control.x-0.5) * 1.0;
	float3 color = texColor.rgb;
	float luminosity = 0.299 * texColorConstrast.r + 0.587 * texColorConstrast.g + 0.114 * texColorConstrast.b;
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
		
	texColor.rgb = lerp(texColorConstrast.rgb, color.rgb, 1.0-Control.y);
	
	pixelColor = texColor*vertexTCoord1*ShineEmissive;
}
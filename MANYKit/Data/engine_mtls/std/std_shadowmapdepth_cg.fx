float linearizedepth(float depth, float4 cameraparam)
{
    float z = (depth - cameraparam.x)/(cameraparam.y - cameraparam.x);
	return z;
}

void v_std_shadowmapdepth
(
    in float3 modelPosition : POSITION,
    in float2 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	out float2 vertexTCoord1 : TEXCOORD1,
    uniform float4x4 PVWMatrix,
	uniform float4x4 VWMatrix,
	uniform float4 ProjectorParam
)
{
    clipPosition = mul(PVWMatrix, float4(modelPosition, 1.0f));
	float4 viewPos = mul(VWMatrix, float4(modelPosition, 1.0f));
    vertexTCoord0 = modelTCoord0;
	vertexTCoord1.x = linearizedepth(viewPos.z, ProjectorParam);
}

sampler2D SampleBase;

void p_std_shadowmapdepth
(
    in float2 vertexTCoord0 : TEXCOORD0,
	in float2 vertexTCoord1 : TEXCOORD1,
    out float4 pixelColor : COLOR
)
{
    // base
    float2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	
	float4 texColor = tex2D(SampleBase, texCoord);
	if (texColor.a < 0.25)
	{
		discard;
	}
	else
	{
		pixelColor.r = vertexTCoord1.x;
		pixelColor.g = vertexTCoord1.x;
		pixelColor.b = vertexTCoord1.x;
		pixelColor.a = 1.0;
	}
}

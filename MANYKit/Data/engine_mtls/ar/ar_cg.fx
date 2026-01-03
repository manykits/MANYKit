// ar_cg.fx

void v_ar
(
    in float3 modelPosition : POSITION,
    in float2 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	uniform float4x4 PVWMatrix
)
{
    clipPosition = mul(PVWMatrix, float4(modelPosition, 1.0f));
    vertexTCoord0 = modelTCoord0;
}

sampler2D SampleColor;
sampler2D SampleDepth;
sampler2D SampleColorScene;
sampler2D SampleDepthScene;

void p_ar
(
    in float2 vertexTCoord0 : TEXCOORD0,
    out float4 pixelColor : COLOR,
	uniform float4 ARParam
)
{
	float2 uv = float2(vertexTCoord0.x, 1.0f-vertexTCoord0.y);
	float4 colorColor = tex2D(SampleColor, uv);
	float4 depthColor = tex2D(SampleDepth, uv);
	float4 colorSceneColor = tex2D(SampleColorScene, uv);
	float4 depthSceneColor = tex2D(SampleDepthScene, uv);
	
	pixelColor = colorColor;
	
	if (depthSceneColor.r < depthColor.r)
		pixelColor = colorSceneColor;
}
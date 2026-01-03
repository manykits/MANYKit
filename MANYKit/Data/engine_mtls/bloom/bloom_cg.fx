// bloom_cg.fx

void v_bloom
(
    in float3 modelPosition : POSITION,
    in float2 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	uniform float4x4 PVWMatrix
)
{
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));
    vertexTCoord0 = modelTCoord0;
}

sampler2D SampleBase;
sampler2D SampleBloom;

void p_bloom
(
    in float2 vertexTCoord0 : TEXCOORD0,
    out float4 pixelColor : COLOR,
	uniform float4 BloomParam
)
{
    //const float gamma = 2.2;
	float2 uv = float2(vertexTCoord0.x, 1.0f-vertexTCoord0.y);
	float4 baseColor = tex2D(SampleBase, uv);
	float4 bloomColor = tex2D(SampleBloom, uv);
	
	float4 pc = baseColor + bloomColor * BloomParam.r;
	
	//float3 result = float3(1.0) - exp(-pc.rgb * 1.0);     
	//float3 result = pc.rgb / (pc.rgb + vec3(1.0));
    //result = pow(result, float3(1.0 / gamma));	
    //pixelColor = float4(result, 1.0);
	pixelColor = pc;
}
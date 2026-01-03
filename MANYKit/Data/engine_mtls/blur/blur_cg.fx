// blur_cg.fx

void v_blur
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

void p_blur
(
    in float2 vertexTCoord0 : TEXCOORD0,
    out float4 pixelColor : COLOR,
	uniform float4 UVParam,
	uniform float4 Control
)
{
    float weight[5] = float[] (0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162);
    float2 tex_offset = 1.0 / float2(UVParam.x, UVParam.y);
	float2 uv = float2(vertexTCoord0.x, 1.0f-vertexTCoord0.y);
	float4 lastcolor = tex2D(SampleBase, uv) * weight[0];
	
	float2 uvoffset;	
	for(int i=1; i < 5; ++i)
	{
	    uvoffset = float2(tex_offset.x * i * Control.x, tex_offset.y * i * (1.0-Control.x));
	
		lastcolor += tex2D(SampleBase, uv + uvoffset) * weight[i];
		lastcolor += tex2D(SampleBase, uv - uvoffset) * weight[i];
	}

	pixelColor = lastcolor;
}
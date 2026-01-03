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
	uniform float4 TexSize
)
{
	float2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	float2 texelSize1 = 1.0 / TexSize.xy;
	
	float result = 0.0;
    for (int x = 0; x < 4; ++x) 
    {
        for (int y = 0; y < 4; ++y) 
        {
            float2 offset = float2(float(x)-2.0, float(y)-2.0) * texelSize1.xy;
            result += tex2D(SampleBase, texCoord + offset).r;
        }
    }
	result = result / 16.0;
	
	pixelColor = float4(result,result,result,1.0);
}
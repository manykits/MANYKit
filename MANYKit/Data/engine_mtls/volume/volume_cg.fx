sampler3D SampleBase;

void v_volume
(
    in float3 modelPosition : POSITION,
    in float3 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float3 vertexTCoord0 : TEXCOORD0,
    uniform float4x4 PVWMatrix
)
{
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));
    vertexTCoord0 = modelTCoord0;
}

void p_volume
(
    in float3 vertexTCoord0 : TEXCOORD0,
    out float4 pixelColor : COLOR,
    uniform sampler3D SampleBase
)
{
    pixelColor = tex3D(SampleBase, vertexTCoord0);
}

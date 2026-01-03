// hdr_cg.fx

void v_hdr
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

void p_hdr
(
    in float2 vertexTCoord0 : TEXCOORD0,
    out float4 pixelColor : COLOR,
	uniform float4 Control
)
{
	float2 uv = float2(vertexTCoord0.x, 1.0f-vertexTCoord0.y);
	float4 baseColor = tex2D(SampleBase, uv);

	const float gamma = 2.2;
    float3 hdrColor = baseColor.rgb;
    if(Control.x > 0.0)
    {
        // reinhard
        float3 result = hdrColor / (hdrColor + vec3(1.0));
        // exposure
        //vec3 result = vec3(1.0) - exp(-hdrColor * Control.y);
        // also gamma correct while we're at it

        result = pow(result, vec3(1.0 / gamma));
        pixelColor = vec4(result, 1.0);
    }
    else
    {
        vec3 result = pow(hdrColor, vec3(1.0 / gamma));
        pixelColor = vec4(result, 1.0);
    }
}
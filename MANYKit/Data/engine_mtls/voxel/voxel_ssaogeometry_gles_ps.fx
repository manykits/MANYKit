// voxel_ssaogeometry_cg.fx

void v_voxel_ssaogeometry
(
    in float3 modelPosition : POSITION,
	in float3 modelNormal : NORMAL,
    in float2 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float3 fragPos : TEXCOORD0,
	out float2 texCoords : TEXCOORD1,
	out float3 normal : TEXCOORD2,    
	uniform float4x4 PVWMatrix,
	uniform float4x4 VWMatrix
)
{
    // Pos
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));
	
	// viewPos
	float4 viewPos = mul(VWMatrix, float4(modelPosition,1.0f));
	fragPos = viewPos.xyz;

    // Tex Coord
    texCoords = modelTCoord0;
	
	// normal
	float3x3 normalMatrix = transpose(inverse((float3x3)VWMatrix));
	normal = mul(normalMatrix, modelNormal);
}

void p_voxel_ssaogeometry
(
    in float3 fragPos : TEXCOORD0, // fragPos
	in float2 texCoords : TEXCOORD1, // texCoords
	in float3 normal : TEXCOORD2, // normal 
    out float4 pixelColor : COLOR, // gPosition
	out float4 pixelColor1 : COLOR1, // gNormal
    out float4 pixelColor2 : COLOR2 // gAlbedo
)
{
	pixelColor = float4(fragPos, 1.0);
	pixelColor1 = float4(normalize(normal), 1.0);
	pixelColor2 = float4(0.6, 0.6, 0.6, 1.0);
}

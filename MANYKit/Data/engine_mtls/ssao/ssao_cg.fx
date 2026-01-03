// ssao_cg.fx

void v_ssao
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

sampler2D SampleGPosition;
sampler2D SampleGNormal;
sampler2D SampleNoise;

void p_ssao
(
    in float2 vertexTCoord0 : TEXCOORD0,
    out float4 pixelColor : COLOR,
	uniform float4x4 PMatrixSet,
	uniform float4 Samples[24]
)
{
	float radius = 0.5;
	float bias = 0.025;
	float2 noiseScale = float2(1136.0/4.0, 640.0/4.0); 
	
	float2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	float4 fragPos = tex2D(SampleGPosition, texCoord);
	float3 normal = normalize(tex2D(SampleGNormal, texCoord).xyz);
	float3 randomVec = normalize(tex2D(SampleNoise, texCoord * noiseScale).xyz); // (x,z: -1 - 1)
	float3 tangent = normalize(randomVec + normal * dot(randomVec, normal));
	float3 bitangent = cross(normal, tangent);
	float3x3 TBN = float3x3(tangent, bitangent, normal);
	
	float occlusion = 0.0;
	float3 samplePos;		
	float4 offset;
	float sampleDepth = 0.0;
	float rangeCheck = 0.0;
	for(int i = 0; i < 24; ++i)
	{
		samplePos.x = dot(tangent, Samples[i].xyz);
		samplePos.y = dot(bitangent, Samples[i].xyz);
		samplePos.z = dot(normal, Samples[i].xyz);
		samplePos = fragPos.xyz - samplePos * radius; 
		
		offset.xyz = samplePos;
		offset.w = 1.0;
		
		offset = mul(PMatrixSet, offset);
        offset.xyz /= offset.w;
        offset.xyz = offset.xyz * 0.5 + 0.5;  // transform to range 0.0 - 1.0
		
		sampleDepth = tex2D(SampleGPosition, offset.xy).z;
		
		rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        occlusion += (sampleDepth >= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;   
	}
	
	occlusion = 1.0 - (occlusion / 24.0);
	
	pixelColor = float4(occlusion, occlusion, occlusion, 1.0);
}
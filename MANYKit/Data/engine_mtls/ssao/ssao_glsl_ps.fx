#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;

uniform sampler2D SampleGPosition;
uniform sampler2D SampleGNormal;
uniform sampler2D SampleNoise;
uniform mat4 PMatrixSet;
uniform vec4 Samples[64];

void main()
{	
	float radius = 0.5;
	float bias = 0.025;
	vec2 noiseScale = vec2(1136.0/4.0, 640.0/4.0); 
	
	vec2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;

	vec4 fragPos = texture(SampleGPosition, texCoord);
	vec3 normal = normalize(texture(SampleGNormal, texCoord).xyz);
	vec3 randomVec = normalize(texture(SampleNoise, texCoord * noiseScale).xyz); // (x,z: -1 - 1)
	vec3 tangent = normalize(randomVec + normal * dot(randomVec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 TBN = mat3(tangent, bitangent, normal);
	
	float occlusion = 0.0;
	for(int i = 0; i < 64; ++i)
	{
		vec3 samplePos = TBN * Samples[i].xyz; 
		samplePos = fragPos.xyz + samplePos * radius; 
		
   		vec4 offset = vec4(samplePos, 1.0);
		
		offset = PMatrixSet * offset;
        offset.xyz /= offset.w;
        offset.xyz = offset.xyz * 0.5 + 0.5;  // transform to range 0.0 - 1.0
		
		float sampleDepth = texture(SampleGPosition, offset.xy).z;
		
		float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        occlusion += (sampleDepth >= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;   
	}
	
	occlusion = (occlusion / 64.0);
	
	pixelColor = vec4(occlusion, occlusion, occlusion, 1.0);
}
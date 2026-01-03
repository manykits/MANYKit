// float4 SkyParam = float4(50.0f, 2.0f, 0.0f, 0.0f); 		// hazeTopAltitude, dayToSunsetSharpness

void v_sky
(
	in float3 modelPosition : POSITION,
	out float4 clipPosition : POSITION,
	out float3 vertexTCoord0 : TEXCOORD0,
	out float2 vertexTCoord1 : TEXCOORD1,
	uniform float4x4 PVWMatrix,
	uniform float4x4 VMatrix,
	uniform float4 CameraWorldPosition,
	uniform float4 FogParam
)
{	
	clipPosition = mul(PVWMatrix, float4(modelPosition, 1.0f));
	float4 worldPosition = mul(VMatrix, float4(modelPosition, 1.0f));
	vertexTCoord0 = worldPosition.xyz - CameraWorldPosition.xyz;
	
	float dist = distance(CameraWorldPosition.xyz, worldPosition.xyz);

	// fog
	float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0, 1.0);	
	float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0, 1.0);
	
	vertexTCoord1.x = fogValueHeight;
	vertexTCoord1.y = fogValueDist;
}

sampler2D SampleDay;
sampler2D SampleSunset;
sampler2D SampleNight;

void p_sky
(
	in float3 vertexTCoord0 : TEXCOORD0,
	in float2 vertexTCoord1 : TEXCOORD1,
	out float4 pixelColor : COLOR,
	uniform float4 LightWorldDVector_Dir,
	uniform float4 CameraWorldDVector,
	uniform float4 SkyParam,
	uniform float4 FogColorHeight,
	uniform float4 FogColorDist
)
{
	float3 camToVertex = normalize(vertexTCoord0);
	
	float3 flatLightVec = normalize(float3(-LightWorldDVector_Dir.x, -LightWorldDVector_Dir.y, 0.0f));
	float3 flatCameraVec = normalize(float3(LightWorldDVector_Dir.x, CameraWorldDVector.y, 0.0f));
	float lcDot = dot(flatLightVec, flatCameraVec);
	float u =  1.0f - (lcDot + 1.0f) * 0.5f;
	
	float val = lerp(0.25, 1.25, min(1, SkyParam[0] / max(0.0001, -LightWorldDVector_Dir.z)));	
	float yAngle = pow(max(0, camToVertex.z), val);	
	float v =  1.0f - yAngle;
	
	float4 colorDay = tex2D(SampleDay, float2(u, v));
	float4 colorSunSet = tex2D(SampleSunset, float2(u, v));
	float4 colorNight = tex2D(SampleNight, float2(u, v));
	
	float4 lastColor = float4(0,0,0,1);
	if (LightWorldDVector_Dir.z < 0.0)
		lastColor = lerp(colorDay, colorSunSet, min(1, pow(1 + LightWorldDVector_Dir.z, SkyParam[1])));
	else 
		lastColor = lerp(colorSunSet, colorNight, min(1, LightWorldDVector_Dir.z * 4));
		
	lastColor.rgb = lerp(FogColorHeight.rgb, lastColor.rgb, vertexTCoord1.x);
	lastColor.rgb = lerp(FogColorDist.rgb, lastColor.rgb, vertexTCoord1.y);
	
	float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
	float3 color = float3(luminosity, luminosity, luminosity);
	if (0==FogColorHeight.w)
	{
		color = float3(luminosity, luminosity, luminosity);
	}
	else if (1==FogColorHeight.w)
	{
		color = float3(1.0, luminosity, luminosity);
	}
	else if (2==FogColorHeight.w)	
	{
		color = float3(luminosity, 1.0, luminosity);	
	}
	else if (3==FogColorHeight.w)	
	{
		color = float3(luminosity, luminosity, 1.0);	
	}
		
	lastColor.rgb = lerp(lastColor.rgb, color.rgb, FogColorDist.a);
	
	pixelColor = lastColor;
}

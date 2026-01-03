float3 DoLight_Point_Diffuse(float3 lightWorldPos, float lightRange, float3 lightColor, float3 shineDiffuse, float3 vertexWorldPos, float3 vertexWorldNormal)
{
    float3 lightToVertex = lightWorldPos - vertexWorldPos;
	lightToVertex = normalize(lightToVertex);		
	float dist = distance(lightWorldPos, vertexWorldPos);
	return lightColor * shineDiffuse * max(0.0, dot(vertexWorldNormal, lightToVertex)) * max( 0.0, (1.0 - dist / lightRange) );
}

void v_voxel_light
(
    in float3 modelPosition : POSITION,
	in float3 modelNormal : NORMAL,
    in float2 modelTCoord0 : TEXCOORD0,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	out float2 vertexTCoord1 : TEXCOORD1,
	out float4 vertexTCoord2 : TEXCOORD2,
    uniform float4x4 PVWMatrix,
	uniform float4x4 WMatrix,
	uniform float4 CameraWorldPosition,
	uniform float4 LightWorldDVector_Dir,
	uniform float4 ShineEmissive,
	uniform float4 ShineAmbient,
	uniform float4 ShineDiffuse,
	uniform float4 ShineSpecular,	
	uniform float4 LightAmbient_Dir,
	uniform float4 LightDiffuse_Dir,
	uniform float4 LightSpecular_Dir,
	uniform float4 LightGroup[6],
	uniform float4 FogParam
)
{
    // Pos
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));

    // Tex Coord
    vertexTCoord0 = modelTCoord0;
	
	// params
	float4 worldPosition = mul(WMatrix, float4(modelPosition, 1.0f));
	float3 worldNormal = normalize(mul((float3x3)WMatrix, modelNormal));	
	
	float3 viewVector = normalize(CameraWorldPosition.xyz - worldPosition.xyz);
	float dist = distance(CameraWorldPosition.xyz, worldPosition.xyz);
	
	// light
	float3 halfVector = normalize((viewVector - LightWorldDVector_Dir.xyz)/2.0);
	float dotH = dot(worldNormal, halfVector);
	
	vertexTCoord2.rgb = ShineEmissive.rgb + LightAmbient_Dir.a * (ShineAmbient.rgb * LightAmbient_Dir.rgb +
		ShineDiffuse.rgb * LightDiffuse_Dir.rgb * max(dot(worldNormal, -LightWorldDVector_Dir.rgb), 0) +
							ShineSpecular.rgb * LightSpecular_Dir.rgb * pow(max(dotH, 0), ShineSpecular.a*LightSpecular_Dir.a));		
	vertexTCoord2.a = ShineEmissive.a;
	
	// point lights
	vertexTCoord2.rgb += DoLight_Point_Diffuse(LightGroup[0].xyz, LightGroup[0].w, LightGroup[1].xyz, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
	vertexTCoord2.rgb += DoLight_Point_Diffuse(LightGroup[2].xyz, LightGroup[2].w, LightGroup[3].xyz, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
	vertexTCoord2.rgb += DoLight_Point_Diffuse(LightGroup[4].xyz, LightGroup[4].w, LightGroup[5].xyz, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);

	// fog
	float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0, 1.0);	
	float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0, 1.0);
	
	vertexTCoord1.x = fogValueHeight;
	vertexTCoord1.y = fogValueDist;
}

sampler2D SampleBase;

void p_voxel_light
(
    in float2 vertexTCoord0 : TEXCOORD0,
	in float2 vertexTCoord1 : TEXCOORD1,
	in float4 vertexTCoord2 : TEXCOORD2,
    out float4 pixelColor : COLOR,
	//out float4 pixelColor1 : COLOR1,
	uniform float4 UVOffset,
	uniform float4 FogColorHeight,
	uniform float4 FogColorDist
)
{
    float2 texCoord = vertexTCoord0;
    texCoord.y = 1.0 - vertexTCoord0.y;
	texCoord.xy += UVOffset.xy;
	float4 lastColor = tex2D(SampleBase, texCoord*UVOffset.zw);

	if (lastColor.a < 0.25)
	{
		discard;
	}
	else
	{
		lastColor *= vertexTCoord2;

		if (4==FogColorHeight.w)
		{
			lastColor.rgb = lerp(float3(1.0, 1.0, 1.0), lastColor.rgb, 0.5);
			vertexTCoord1.x = 1.0 - (1.0-vertexTCoord1.x) * 0.2;
			vertexTCoord1.y = 1.0 - (1.0-vertexTCoord1.y) * 0.2;
		}
	
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
	
		// float brightness = dot(lastColor.rgb, vec3(0.2126, 0.7152, 0.0722));
		// if (brightness > 1.0)
		// 	pixelColor1 = lastColor;
		// else	
		// 	pixelColor1 = float4(0.0, 0.0, 0.0, 1.0);
			
		pixelColor = lastColor;
	}
}

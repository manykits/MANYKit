float3 DoLight_Point_Diffuse(float3 lightToVertexDir, float3 lightWorldPos, float lightRange, float3 lightColor, float3 shineDiffuse, float3 vertexWorldPos, float3 vertexWorldNormal)
{
	float dist = distance(lightWorldPos, vertexWorldPos);
	return lightColor * shineDiffuse * max(0, dot(vertexWorldNormal, lightToVertexDir)) * max( 0, (1.0 - dist / lightRange) );
}

void v_voxel_lightnormal
(
    in float3 modelPosition : POSITION,
	in float3 modelNormal : NORMAL,
    in float2 modelTCoord0 : TEXCOORD0,
	in float3 tangent : TEXCOORD1,
	in float3 binormal : TEXCOORD2,
    out float4 clipPosition : POSITION,
    out float2 vertexTCoord0 : TEXCOORD0,
	out float2 vertexTCoord1 : TEXCOORD1, // fog
	out float3 vertexTCoord2 : TEXCOORD2, // t lightdir 
	out float3 vertexTCoord3 : TEXCOORD3, // t viewdir
	out float3 vertexTCoord4 : TEXCOORD4,
	out float4 vertexTCoord5 : TEXCOORD5,
	out float4 vertexTCoord6 : TEXCOORD6,
	out float4 vertexTCoord7 : TEXCOORD7,
    uniform float4x4 PVWMatrix,
	uniform float4x4 WMatrix,
	uniform float4x4 ProjectPVBSMatrix_Dir,
	uniform float4 LightModelDVector_Dir,
	uniform float4 CameraWorldPosition,
	uniform float4 CameraModelPosition,
	uniform float4 LightModelGroup[6],
	uniform float4 FogParam
)
{
    // Pos
    clipPosition = mul(PVWMatrix, float4(modelPosition,1.0f));

    // Tex Coord
    vertexTCoord0 = modelTCoord0;
	
	// params
	float4 worldPosition = mul(WMatrix, float4(modelPosition, 1.0f));	
	float3 worldNormal = mul(float3x3(WMatrix), modelNormal);	
	
	// shadow
    vertexTCoord4 = mul(ProjectPVBSMatrix_Dir, float4(modelPosition, 1.0f));
	
    float3 t = tangent;
	float3 b = binormal;
	float3 n = modelNormal;
	
	// dir
    float3 ldir = -normalize(LightModelDVector_Dir.xyz);
	float3 ldir1;
	ldir1.x = dot(t, ldir);
	ldir1.y = dot(b, ldir);
	ldir1.z = dot(n, ldir);
	vertexTCoord2 = ldir1;
	
	// point 
	float3 p0 = LightModelGroup[0].xyz + LightModelGroup[1].xyz*0.00001;
	float3 p1 = LightModelGroup[2].xyz + LightModelGroup[3].xyz*0.00001;
	float3 p2 = LightModelGroup[4].xyz + LightModelGroup[5].xyz*0.00001;

	float3 lv0 = p0 - modelPosition;
	float3 lv1 = p1 - modelPosition;
	float3 lv2 = p2 - modelPosition;
	
	float3 lv00;
	float3 lv10;
	float3 lv20;
	lv00.x = dot(t, lv0);
	lv00.y = dot(b, lv0);
	lv00.z = dot(n, lv0);
	
	lv10.x = dot(t, lv1);
	lv10.y = dot(b, lv1);
	lv10.z = dot(n, lv1);
	
	lv20.x = dot(t, lv2);
	lv20.y = dot(b, lv2);
	lv20.z = dot(n, lv2);
	
	vertexTCoord5.xyz = lv00;
	vertexTCoord6.xyz = lv10;
	vertexTCoord7.xyz = lv20;
	vertexTCoord5.w = worldPosition.x;
	vertexTCoord6.w = worldPosition.y;
	vertexTCoord7.w = worldPosition.z;
	
	// view
	float3 cdir = normalize(CameraModelPosition.xyz - modelPosition.xyz);	
	float3 cdir1;
	cdir1.x = dot(t, cdir);
	cdir1.y = dot(b, cdir);
	cdir1.z = dot(n, cdir);	
	vertexTCoord3 = cdir1;
	
	// fog
	float dist = distance(CameraWorldPosition.xyz, worldPosition.xyz);
	
	float fogValueHeight = (-FogParam.x + worldPosition.z)/(FogParam.y - FogParam.x);
	fogValueHeight = clamp(fogValueHeight, 0, 1.0);	
	float fogValueDist = (FogParam.w - dist)/(FogParam.w - FogParam.z);
	fogValueDist = clamp(fogValueDist, 0, 1.0);
	
	vertexTCoord1.x = fogValueHeight;
	vertexTCoord1.y = fogValueDist;
}

sampler2D SampleBase;
sampler2D SampleNormal;
sampler2D SampleShadowDepth;

float GetDepth(float4 texCord, int i, int j)
{
	float4 newUV = texCord + float4(texCord.w*i*0.001f, texCord.w*j*0.001f, 0.0f, 0.0f);
	float4 depthColor = tex2Dproj(SampleShadowDepth, newUV);
	//float4 depthColor = tex2D(SampleShadowDepth, float2(newUV.x/texCord.w, newUV.y/texCord.w));
				
	return depthColor.r;
}

void p_voxel_lightnormal
(
    in float2 vertexTCoord0 : TEXCOORD0,
	in float2 vertexTCoord1 : TEXCOORD1,
	in float3 vertexTCoord2 : TEXCOORD2, // t lightdir_t 
	in float3 vertexTCoord3 : TEXCOORD3, // t viewvector_t
	in float4 vertexTCoord4 : TEXCOORD4,
	in float4 vertexTCoord5 : TEXCOORD5,
	in float4 vertexTCoord6 : TEXCOORD6,
	in float4 vertexTCoord7 : TEXCOORD7,
    out float4 pixelColor : COLOR,
	//out float4 pixelColor1 : COLOR1,
	uniform float4 UVOffset,
	uniform float4 FogColorHeight,
	uniform float4 FogColorDist,	
	uniform float4 ShineEmissive,
	uniform float4 ShineAmbient,
	uniform float4 ShineDiffuse,
	uniform float4 ShineSpecular,	
	uniform float4 LightAmbient_Dir,
	uniform float4 LightDiffuse_Dir,
	uniform float4 LightSpecular_Dir,
	uniform float4 LightGroup[6]
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
		// normal
		float3 normalMap = normalize(tex2D(SampleNormal, texCoord*UVOffset.zw).xyz * 2.0 - 1.0);
		
		float3 worldNormal = normalMap;	
		float3 lightdir_t = vertexTCoord2;
		float3 viewvector_t = vertexTCoord3;
		
		float3 p0 = vertexTCoord5.xyz;
		float3 p1 = vertexTCoord6.xyz;
		float3 p2 = vertexTCoord7.xyz;
		float3 worldPosition = float3(vertexTCoord5.w, vertexTCoord6.w, vertexTCoord7.w);
		
		float4 lighting;
		float3 halfVector = normalize((viewvector_t - lightdir_t)/2.0);
		float dotH = max(dot(worldNormal, halfVector), 0.0);
		float dotN = max(dot(worldNormal, lightdir_t), 0.0);
		lighting.rgb = ShineEmissive.rgb + LightAmbient_Dir.a *(ShineAmbient.rgb * LightAmbient_Dir.rgb + ShineDiffuse.rgb * LightDiffuse_Dir.rgb * dotN +
			ShineSpecular.rgb * LightSpecular_Dir.rgb * pow(dotH, ShineSpecular.a*LightSpecular_Dir.a));
		lighting.a = ShineEmissive.a;
		
		lighting.rgb += DoLight_Point_Diffuse(p0, LightGroup[0].xyz, LightGroup[0].w, LightGroup[1].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		lighting.rgb += DoLight_Point_Diffuse(p1, LightGroup[2].xyz, LightGroup[2].w, LightGroup[3].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		lighting.rgb += DoLight_Point_Diffuse(p2, LightGroup[4].xyz, LightGroup[4].w, LightGroup[5].rgb, ShineDiffuse.rgb, worldPosition.xyz, worldNormal.xyz);
		
		// light
		float4 lightColor = lighting;
		
		// shadow map depth
		float4 texCord = vertexTCoord4;
		float shadowDepth = GetDepth(texCord, 0, 0);
		shadowDepth += GetDepth(texCord, -1, -1);
		shadowDepth += GetDepth(texCord, -1, 0);
		shadowDepth += GetDepth(texCord, -1, 1);
		shadowDepth += GetDepth(texCord, 0, -1);
		shadowDepth += GetDepth(texCord, 0, 1);
		shadowDepth += GetDepth(texCord, 1, -1);
		shadowDepth += GetDepth(texCord, 1, 0);
		shadowDepth += GetDepth(texCord, 1, 1);
		shadowDepth *= 0.1111f;
		if (texCord.x<=0.01 ||texCord.x>=0.99||texCord.y<=0.01 ||texCord.y>=0.99)
		{
			shadowDepth = 1.0;
		}	
		shadowDepth	= clamp(shadowDepth, 0.4, 1.0);
		lightColor.rgb *= shadowDepth;		
	
		lastColor.rgb *= lightColor.rgb;
	
		lastColor.rgb = lerp(FogColorHeight.rgb, lastColor.rgb, vertexTCoord1.x);
		lastColor.rgb = lerp(FogColorDist.rgb, lastColor.rgb, vertexTCoord1.y);
		
		// float brightness = dot(lastColor.rgb, float3(0.2126, 0.7152, 0.0722));
		// if (brightness > 1.0)
		// 	pixelColor1 = lastColor;
		// else	
		// 	pixelColor1 = float4(0.0, 0.0, 0.0, 1.0);
	
		pixelColor = lastColor;
	}
}

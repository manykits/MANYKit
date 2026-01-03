#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec2 vertexTCoord0;
in vec4 vertexTCoord1;
in vec4 vertexTCoord2;
in vec4 vertexTCoord3;
in vec4 vertexTCoord4;
uniform sampler2D SampleDuDv;
uniform sampler2D SampleReflection;
uniform vec4 User;
uniform vec4 ShineEmissive;
uniform vec4 ShineAmbient;
uniform vec4 ShineDiffuse;
uniform vec4 ShineSpecular;
uniform vec4 LightWorldDVector_Dir;
uniform vec4 LightAmbient_Dir;
uniform vec4 LightDiffuse_Dir;
uniform vec4 LightSpecular_Dir;

void main()
{
	vec2 modelTCoord0 = vertexTCoord0;
	vec4 worldPosition = vertexTCoord1;
	vec3 worldNormal = vertexTCoord2.xyz;
	float moveFactor = User.z;
	vec4 posProj = vertexTCoord4;

	vec3 distortion1 = (texture(SampleDuDv, vec2(modelTCoord0.x, modelTCoord0.y)*10).xyz*2 - 1) * 0.02;
	vec3 distortion2 = (texture(SampleDuDv, vec2(-modelTCoord0.x + moveFactor, modelTCoord0.y + moveFactor)*10).xyz*2 - 1) * 0.02;
	vec3 totalDistortion = distortion1 + distortion2;

	worldNormal = totalDistortion*50;
	worldNormal.z = 1.0;
	worldNormal = normalize(worldNormal);

	vec4 lastColor = vec4(0.0, 0.0, 0.0, 1.0);
	if( posProj.w>0.0 )
	{
		vec2 cord = posProj.xy / posProj.w;
	    cord += totalDistortion.xy;
	
	    vec4 reflectionColor = texture(SampleReflection, cord);
		lastColor = reflectionColor;
	}

	vec3 lightdir_t = LightWorldDVector_Dir.xyz;
    vec3 viewvector_t = vertexTCoord3.xyz;

	// light
	vec4 lighting = vec4(0.0, 0.0, 0.0, 0.0);
	vec3 halfVector = normalize((viewvector_t - lightdir_t)/2.0);
	float dotH = max(dot(worldNormal, halfVector), 0.0);
	float dotN = max(dot(worldNormal, lightdir_t), 0.0);
	lighting.rgb = ShineEmissive.rgb + LightAmbient_Dir.a *(ShineAmbient.rgb * LightAmbient_Dir.rgb +
		ShineDiffuse.rgb * LightDiffuse_Dir.rgb * dotN +
		ShineSpecular.rgb * LightSpecular_Dir.rgb * max(pow(dotH, ShineSpecular.a*LightSpecular_Dir.a), 0.0));
	lighting.a = ShineEmissive.a;
	lighting *= 0.000001;

	lastColor += lighting;
	
	float brightness = dot(lastColor.rgb, vec3(0.2126, 0.7152, 0.0722));		
	if (brightness > 1.0)
		pixelColor1 = lastColor;
	else	
		pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);

	lastColor.a = 0.8;
	pixelColor = lastColor;	
}
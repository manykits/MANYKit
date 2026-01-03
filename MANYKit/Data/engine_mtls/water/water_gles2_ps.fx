varying mediump vec2 vertexTCoord0;
varying mediump vec4 vertexTCoord1;
varying mediump vec4 vertexTCoord2;
varying mediump vec4 vertexTCoord3;
varying mediump vec4 vertexTCoord4;

uniform sampler2D SampleDuDv;
uniform sampler2D SampleReflection;

uniform mediump vec4 User;
uniform mediump vec4 ShineEmissive;
uniform mediump vec4 ShineAmbient;
uniform mediump vec4 ShineDiffuse;
uniform mediump vec4 ShineSpecular;
uniform mediump vec4 LightWorldDVector_Dir;
uniform mediump vec4 LightAmbient_Dir;
uniform mediump vec4 LightDiffuse_Dir;
uniform mediump vec4 LightSpecular_Dir;

void main()
{
	mediump vec3 worldNormal = vertexTCoord2.xyz;
	mediump float moveFactor = User.z * 0.01;
	mediump vec4 posProj = vertexTCoord4;
	
	mediump vec2 modelTCoord00 = vec2(vertexTCoord0.x*500.0, vertexTCoord0.y*500.0);
	mediump vec2 modelTCoord11 = vec2((-vertexTCoord0.x + moveFactor)*500.0, (vertexTCoord0.y + moveFactor)*500.0);

	mediump vec3 distortion1 = (texture2D(SampleDuDv, modelTCoord00).xyz*2.0 - 1.0) * 0.02;
	mediump vec3 distortion2 = (texture2D(SampleDuDv, modelTCoord11).xyz*2.0 - 1.0) * 0.02;
	mediump vec3 totalDistortion = distortion1 + distortion2;

	worldNormal = totalDistortion*50.0;
	worldNormal.z = 1.0;
	worldNormal = normalize(worldNormal);

	mediump vec4 lastColor = vec4(0.0, 0.0, 0.0, 1.0);
	if( posProj.w>0.0 )
	{
		mediump vec2 cord = posProj.xy / posProj.w;
	    cord += totalDistortion.xy;
	
	    mediump vec4 reflectionColor = texture2D(SampleReflection, cord);
		lastColor = reflectionColor;
	}

	mediump vec3 lightdir_t = LightWorldDVector_Dir.xyz;
    mediump vec3 viewvector_t = vertexTCoord3.xyz;

	// light
	mediump vec4 lighting = vec4(0.0, 0.0, 0.0, 0.0);
	mediump vec3 halfVector = normalize((viewvector_t - lightdir_t)/2.0);
	mediump float dotH = max(dot(worldNormal, halfVector), 0.0);
	mediump float dotN = max(dot(worldNormal, lightdir_t), 0.0);
	lighting.rgb = ShineEmissive.rgb + LightAmbient_Dir.a *(ShineAmbient.rgb * LightAmbient_Dir.rgb +
		ShineDiffuse.rgb * LightDiffuse_Dir.rgb * dotN +
		ShineSpecular.rgb * LightSpecular_Dir.rgb * max(pow(dotH, ShineSpecular.a*LightSpecular_Dir.a), 0.0));
	lighting.a = ShineEmissive.a;
	lighting *= 0.000001;

	lastColor += lighting;

	lastColor.a = 0.8;
	gl_FragColor = lastColor;
}
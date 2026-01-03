varying mediump vec3 vertexTCoord0;
varying mediump vec2 vertexTCoord1;
uniform mediump vec4 LightWorldDVector_Dir;
uniform mediump vec4 CameraWorldDVector;
uniform mediump vec4 SkyParam;
uniform mediump vec4 SunMoonParam;
uniform mediump vec4 SunMoonColourIn;
uniform mediump vec4 SunMoonColourOut;
uniform mediump vec4 FogColorHeight;
uniform mediump vec4 FogColorDist;

uniform sampler2D SampleDay;
uniform sampler2D SampleSunset;
uniform sampler2D SampleNight;


mediump float LerpFloat(mediump float val0, mediump float val1, mediump float alpha)
{
	return val0 * (1.0 - alpha) + val1 * alpha;
}

mediump vec4 LerpColor(mediump vec4 color0, mediump vec4 color1, mediump float alpha)
{
	return color0 * (1.0-alpha) + color1 * alpha;
}

void main()
{
	mediump vec3 camToVertex = normalize(vertexTCoord0);
	
	mediump vec3 flatLightVec = normalize(vec3(-LightWorldDVector_Dir.x, -LightWorldDVector_Dir.y, 0.0));
	mediump vec3 flatCameraVec = normalize(vec3(CameraWorldDVector.x, CameraWorldDVector.y, 0.0));
	mediump float lcDot = dot(flatLightVec, flatCameraVec);
	mediump float u =  1.0 - (lcDot + 1.0) * 0.5;
	
	mediump float val = LerpFloat(0.25, 1.25, min(1.0, SkyParam[0] / max(0.0001, -LightWorldDVector_Dir.z)));	
	mediump float yAngle = pow(max(0.0, camToVertex.z), val);	
	mediump float v =  1.0 - yAngle;
	
	mediump vec4 colorDay = texture2D(SampleDay, vec2(u, v));
	mediump vec4 colorSunSet = texture2D(SampleSunset, vec2(u, v));
	mediump vec4 colorNight = texture2D(SampleNight, vec2(u, v));
	
	mediump vec4 lastColor = vec4(0.0, 0.0, 0.0, 1.0);
	if (LightWorldDVector_Dir.z < 0.0)
		lastColor = LerpColor(colorDay, colorSunSet, min(1.0, pow((1.0 + LightWorldDVector_Dir.z), SkyParam[1])));
	else
		lastColor = LerpColor(colorSunSet, colorNight, min(1.0, LightWorldDVector_Dir.z * 4.0));
	
	mediump float sunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[0]) * SunMoonParam[1];	
	mediump float largeSunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[2]) * SunMoonParam[3];
	lastColor +=  SunMoonColourIn * sunHighLight + SunMoonColourOut * largeSunHighLight;
	
	lastColor.rgb = lastColor.rgb * vertexTCoord1.x + FogColorHeight.rgb * (1.0 - vertexTCoord1.x);
	lastColor.rgb = lastColor.rgb * vertexTCoord1.y + FogColorDist.rgb * (1.0 - vertexTCoord1.y);
	
	mediump float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
	mediump vec3 color = vec3(luminosity, luminosity, luminosity);
	if (0.0==FogColorHeight.w)
	{
		color = vec3(luminosity, luminosity, luminosity);
	}
	else if (1.0==FogColorHeight.w)
	{
		color = vec3(1.0, luminosity, luminosity);
	}
	else if (2.0==FogColorHeight.w)	
	{
		color = vec3(luminosity, 1.0, luminosity);	
	}
	else if (3.0==FogColorHeight.w)	
	{
		color = vec3(luminosity, luminosity, 1.0);	
	}

	lastColor.rgb = mix(lastColor.rgb, color.rgb, FogColorDist.a);	
		
	gl_FragColor = lastColor;
}
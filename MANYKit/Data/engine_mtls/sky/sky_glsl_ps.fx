#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec3 vertexTCoord0;
in vec2 vertexTCoord1;
uniform vec4 LightWorldDVector_Dir;
uniform vec4 CameraWorldDVector;
uniform vec4 SkyParam;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;

uniform sampler2D SampleDay;
uniform sampler2D SampleSunset;
uniform sampler2D SampleNight;

float LerpFloat( float val0,  float val1,  float alpha)
{
	return val0 * (1.0 - alpha) + val1 * alpha;
}

vec4 LerpColor( vec4 color0,  vec4 color1,  float alpha)
{
	return color0 * (1.0-alpha) + color1 * alpha;
}

void main()
{
	vec3 camToVertex = normalize(vertexTCoord0);
	
	vec3 flatLightVec = normalize(vec3(-LightWorldDVector_Dir.x, -LightWorldDVector_Dir.y, 0.0));
	vec3 flatCameraVec = normalize(vec3(CameraWorldDVector.x, CameraWorldDVector.y, 0.0));
	float lcDot = dot(flatLightVec, flatCameraVec);
	float u =  1.0 - (lcDot + 1.0) * 0.5;
	
	float val = LerpFloat(0.25, 1.25, min(1.0, SkyParam[0] / max(0.0001, -LightWorldDVector_Dir.z)));	
	float yAngle = pow(max(0.0, camToVertex.z), val);	
	float v =  1.0 - yAngle;
	
	vec4 colorDay = texture(SampleDay, vec2(u, v));
	vec4 colorSunSet = texture(SampleSunset, vec2(u, v));
	vec4 colorNight = texture(SampleNight, vec2(u, v));
	
	vec4 lastColor = vec4(0.0, 0.0, 0.0, 1.0);
	if (LightWorldDVector_Dir.z < 0.0)
		lastColor = LerpColor(colorDay, colorSunSet, min(1.0, pow((1.0 + LightWorldDVector_Dir.z), SkyParam[1])));
	else
		lastColor = LerpColor(colorSunSet, colorNight, min(1.0, LightWorldDVector_Dir.z * 4.0));		
	
	lastColor.rgb = lastColor.rgb * vertexTCoord1.x + FogColorHeight.rgb * (1.0 - vertexTCoord1.x);
	lastColor.rgb = lastColor.rgb * vertexTCoord1.y + FogColorDist.rgb * (1.0 - vertexTCoord1.y);
	
	float luminosity = 0.299 * lastColor.r + 0.587 * lastColor.g + 0.114 * lastColor.b;
	vec3 color = vec3(luminosity, luminosity, luminosity);
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
		
	float brightness = dot(lastColor.xyz, vec3(0.2126, 0.7152, 0.0722));
	if (brightness > 1.0)
		pixelColor1 = lastColor;
	else	
		pixelColor1 = vec4(0.0, 0.0, 0.0, 1.0);

	pixelColor = lastColor;	
}
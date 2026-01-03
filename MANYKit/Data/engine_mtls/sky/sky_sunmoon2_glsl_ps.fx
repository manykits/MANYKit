#version 330 core

layout (location = 0) out vec4 pixelColor;
layout (location = 1) out vec4 pixelColor1;

in vec3 vertexTCoord0;
in vec2 vertexTCoord1;
in vec4 vertexTCoord2;
uniform vec4 LightWorldDVector_Dir;
uniform vec4 CameraWorldDVector;
uniform vec4 CameraWorldPosition;
uniform vec4 SkyParam;
uniform vec4 SunMoonParam;
uniform vec4 SunMoonColourIn;
uniform vec4 SunMoonColourOut;
uniform vec4 FogColorHeight;
uniform vec4 FogColorDist;
uniform vec4 CloudBaseBright; // color, step
uniform vec4 CloudBaseDark; // color, spd_x
uniform vec4 CloudLightBright; // color, sp_y
uniform vec4 CloudLightDark; // color, clip
uniform vec4 User;

uniform sampler2D SampleDay;
uniform sampler2D SampleSunset;
uniform sampler2D SampleNight;
uniform sampler3D SampleCloudShape;
uniform sampler3D SampleCloudDetail;

const vec3 _offset = vec3(1.0, 1.358, 0.0);
const vec4 _shape = vec4(0.159, 0.5, 0.25, 0.17);
const vec3 _detail = vec3(0.4, 0.1, 0.1);

const vec3 _lightColor = vec3(0.804,0.771,0.662);
const vec3 _cloudColor = vec3(0.809,0.734,0.819);

const int RAY_MARCHING_STEPS = 64;
const float INF = 9999;
const float EPSILON = 0.0001;
const float PI = 3.1415926;

struct Box
{
	vec3 position;
	vec3 scale;
} _box;

vec3 GetLocPos(vec3 pos)
{
	// sampling as 4D texture
	float time = User.x;
	pos = ( (pos -_box.position)/(_box.scale) + vec3(1,1,1+abs(sin(time*0.1) ) ) ) * 0.5;

	return pos;
}

Box CreateBox(vec3 position, vec3 scale)
{
	Box box;
	box.position = position;
	box.scale = scale;
	return box;
}

float Remap(float v, float l0, float h0, float ln, float hn)
{
	return ln + ((v - l0) * (hn - ln)) / (h0 - l0);
}

float SAT(float v)
{
	if(v > 1) return 1;
	if(v < 0) return 0;
	return v;
}

float SampleDensity(vec3 p)
{	
	// p is world pos
	vec3 shapePose = min(vec3(0.95), max(vec3(0.05), fract(GetLocPos(p)*_offset.x) ) );

	vec4 cloudShape = texture(SampleCloudShape, shapePose);	

	// calculate base shape density
	// Refer: Sebastian Lague @ Code Adventure
	float boxBottom = _box.position.z - _box.scale.z;
	float heightPercent = (p.z - boxBottom) / (_box.scale.z);
	float heightGradient = SAT(Remap(heightPercent, 0.0, 0.2,0,1)) * SAT(Remap(heightPercent, 1, 0.7, 0,1));
	float shapeFBM = dot(cloudShape, _shape)*heightGradient;
	
	if(shapeFBM > 0)
	{
		vec3 detailPos = min(vec3(0.95),max(vec3(0.05),fract(GetLocPos(p)*4*_offset.y)));

		vec4 cloudDetail =  texture(SampleCloudDetail, detailPos);
		
		// Subtract detail noise from base shape (weighted by inverse density so that edges get erodes more than center)
		float detailErodeWeight = pow((1 - shapeFBM), 3);
		float detailFBM = dot(cloudDetail.xyz, _detail)*0.6;
		float density = shapeFBM - (1 - detailFBM)*detailErodeWeight*100;
		if(density < 0)
			return 0;
		else 
			return density*10;
	}

	return -1;
}

struct Ray
{
    vec3 origin;
    vec3 direction;
};

Ray CreateRay(vec3 origin, vec3 direction)
{
    Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    return ray;
}


Ray CreateCameraRay(vec3 camwpos, vec3 dir)
{
    return CreateRay(camwpos, dir);
}

struct RayHit{
	vec3 position;
	float hitDist;
	float alpha;
	float entryPoint;
	float exitPoint;
};

RayHit CreateRayHit()
{
	RayHit hit;
	hit.position = vec3(0,0,0);
	hit.hitDist = INF;
	hit.alpha = 0;
	hit.entryPoint = 0;
	hit.exitPoint = INF;
	
	return hit;
}

void IntersectBox(Ray ray, inout RayHit bestHit, Box box)
{
	vec3 minBound = box.position - box.scale;
	vec3 maxBound = box.position + box.scale;

	vec3 t0 = (minBound - ray.origin) / ray.direction;
	vec3 t1 = (maxBound - ray.origin) / ray.direction;

	vec3 tsmaller = min(t0, t1);
	vec3 tbigger = max(t0, t1);

	float tmin = max(tsmaller[0], max(tsmaller[1], tsmaller[2]));
    float tmax = min(tbigger[0], min(tbigger[1], tbigger[2]));

	if(tmin > tmax) 
		return;

	// else
	// Hit a box!
	if(tmax > 0 && tmin < bestHit.hitDist)
	{
		if(tmin < 0) tmin = 0;
		bestHit.hitDist = tmin;
		bestHit.position = ray.origin + bestHit.hitDist * ray.direction;
		bestHit.alpha = 1;
		// For volumetric rendering
		bestHit.entryPoint = tmin;
		bestHit.exitPoint = tmax;
	}
}

RayHit CastRay(Ray ray)
{
	RayHit bestHit = CreateRayHit();
	IntersectBox(ray, bestHit, _box);
	return bestHit;
}

vec3 sunDir = vec3(0,1,0);
const int LIGHT_MARCH_NUM = 8;
float lightMarch(vec3 p)
{
	float totalDensity = 0; 
	vec3 lightDir = normalize(sunDir);
	Ray lightRay = CreateRay(p, lightDir);
	RayHit lightHit = CreateRayHit();
	IntersectBox(lightRay, lightHit, _box);

	// the distance inside the cloud box
	float distInBox = abs(lightHit.exitPoint - lightHit.entryPoint);

	float stepSize = distInBox / float(LIGHT_MARCH_NUM);
	for(int i = 0; i < LIGHT_MARCH_NUM; i++)
	{
		p += lightDir*stepSize;
		totalDensity += max(0.0, SampleDensity(p)/8*stepSize);
	}
	float transmittance = exp(-totalDensity*2);
	float darknessThreshold = 0.6;
	return darknessThreshold + transmittance*(1-darknessThreshold);
}

void Volume(Ray ray, RayHit hit, inout vec4 result)
{
	vec3 start = hit.position;
	vec3 end = hit.position + ray.direction*abs(hit.exitPoint-hit.entryPoint);
	float len = distance(start, end);
	float stepSize = len / float(RAY_MARCHING_STEPS);

	vec3 eachStep =  stepSize * normalize(end - start);
	vec3 currentPos = start;

	float lightEnergy = 0;
	float transmittance = 1;
	for(int i = 0; i < RAY_MARCHING_STEPS; i++)
	{
		float density = SampleDensity(currentPos);
		if(density > 0)
		{
			// Sample the cloud on the direction to the sun (parallel light)
			float lightTransmittance = lightMarch(currentPos);
			lightEnergy += density*stepSize*transmittance*lightTransmittance;

			// larger density, smaller transmittance
			transmittance *= exp(-density*stepSize*0.643);

			if(transmittance < 0.01 || lightEnergy > 2)
			{
				break;
			}

		}
		currentPos += eachStep;	 	
	}

	 vec3 cloudColor = lightEnergy * _lightColor * _cloudColor;
	 result.xyz = result.xyz*transmittance + cloudColor;
}

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
	_box = CreateBox(vec3(0, 0, 500), vec3(500, 500, 200));

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
	
	float sunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[0]) * SunMoonParam[1];	
	float largeSunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[2]) * SunMoonParam[3];
	lastColor +=  SunMoonColourIn * sunHighLight + SunMoonColourOut * largeSunHighLight;
	
	if (SkyParam[2]>0)
	{
    	Ray ray = CreateCameraRay(CameraWorldPosition.xyz, camToVertex);
		RayHit hit = CreateRayHit();
		hit = CastRay(ray);
		if(hit.alpha != 0)
		{
			Volume(ray, hit, lastColor);
		}
	}

	//lastColor.rgb = lastColor.rgb * vertexTCoord1.x + FogColorHeight.rgb * (1.0 - vertexTCoord1.x);
	//lastColor.rgb = lastColor.rgb * vertexTCoord1.y + FogColorDist.rgb * (1.0 - vertexTCoord1.y);

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
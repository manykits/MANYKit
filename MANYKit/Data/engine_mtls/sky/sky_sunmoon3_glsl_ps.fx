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
uniform vec4 CloudRanage; // bottom top width, numStep
uniform vec4 CloudBaseBright; // color, step
uniform vec4 CloudBaseDark; // color, spd_x
uniform vec4 CloudLightBright; // color, sp_y
uniform vec4 CloudLightDark; // color, clip

uniform sampler2D SampleDay;
uniform sampler2D SampleSunset;
uniform sampler2D SampleNight;
uniform sampler3D SampleCloud;

float noise(sampler3D noisetex, vec3 uv)
{
	return texture(noisetex, uv).b;
} 

float getCloudNoise(sampler3D noisetex, vec3 worldPos) {
    vec3 coord = worldPos;
    coord *= 0.001;

	float spd_x = CloudBaseDark.w;
	float spd_y = CloudLightBright.w;
	float spd_z = CloudLightBright.w;

	coord.x += spd_x * 0.01;
	coord.y += spd_y * 0.01;
	coord.z += spd_z * 0.0;
	
    float n  = noise(noisetex, coord) * 0.5;

	coord *= 3.0;
    n += noise(noisetex, coord) * 0.25; 
	
	coord *= 3.01;
    n += noise(noisetex, coord) * 0.125;
	
	coord *= 3.02;
	n += noise(noisetex, coord) * 0.0625;
		  
    return max(n - CloudLightDark.w, 0.0) * (1.0 / (1.0 - CloudLightDark.w));
}

vec4 getCloud(sampler3D noisetex, vec3 worldPos, vec3 cameraPos, vec3 lightDir) {
    vec3 direction = normalize(worldPos - cameraPos);   // 视线射线方向
    vec3 step = direction * CloudBaseBright.w;   // 步长
    vec4 colorSum = vec4(0);        // 积累的颜色
    vec3 pt = cameraPos;         // 从相机出发开始测试

	float bottom = CloudRanage.x;
	float top = CloudRanage.y;
	pt += direction * 150.0;

	float len1 = length(pt - cameraPos);     // 云层到眼距离
    float len2 = length(worldPos - cameraPos);  // 目标像素到眼距离
    if(len2<len1) {
        return vec4(0);
    }

    // ray marching
	float numStep = CloudRanage.w;
    for(int i=0; i<numStep; i++) {
        pt += step;

		float dz2 = pt.x*pt.x + pt.y*pt.y; 
		float r2 = CloudRanage.z * CloudRanage.z;

        if(CloudRanage.x>pt.z || pt.z>CloudRanage.y ) {
            continue;
        }
        
		// 采样
		float density = getCloudNoise(noisetex, pt);                // 当前点云密度
		float lightDensity = getCloudNoise(noisetex, pt - lightDir);// 向光源方向采样一次 获取密度
		float delta = clamp(density - lightDensity, 0.0, 1.0);      // 两次采样密度差

		// 控制透明度
		density *= max(1.0 - dz2/r2, 0.1) * clamp((pt.z-CloudRanage.x)*(pt.z-CloudRanage.x)/2000.0, 0.0, 1.0);

		// 颜色计算
		vec3 base = mix(CloudBaseBright.xyz, CloudBaseDark.xyz, density) * density;   // 基础颜色
		vec3 light = mix(CloudLightDark.xyz, CloudLightBright.xyz, delta);            // 光照对颜色影响

		// 混合
		vec4 color = vec4(base*light, density);                     // 当前点的最终颜色
		colorSum = color * (1.0 - colorSum.a) + colorSum;           // 与累积的颜色混合
    }

    return colorSum;
}

float LerpFloat( float val0,  float val1,  float alpha)
{
	return val0 * (1.0 - alpha) + val1 * alpha;
}
vec4 LerpColor( vec4 color0,  vec4 color1,  float alpha)
{
	return color0 * (1.0-alpha) + color1 * alpha;
}

const float INF = 9999;
const float EPSILON = 0.0001;
const float PI = 3.1415926;

struct Box
{
	vec3 position;
	vec3 scale;
} _box;
Box CreateBox(vec3 position, vec3 scale)
{
	Box box;
	box.position = position;
	box.scale = scale;
	return box;
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
	
	float sunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[0]) * SunMoonParam[1];	
	float largeSunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[2]) * SunMoonParam[3];
	lastColor +=  SunMoonColourIn * sunHighLight + SunMoonColourOut * largeSunHighLight;
	
	_box = CreateBox(vec3(0, 0, 300), vec3(1000, 1000, 200));
	if (SkyParam[2]>0)
	{
		Ray ray = CreateCameraRay(CameraWorldPosition.xyz, camToVertex);
		RayHit hit = CreateRayHit();
		hit = CastRay(ray);
		if(hit.alpha != 0)
		{
			vec3 cpos = vec3(0, 0, 0);
			vec4 cloud = getCloud(SampleCloud, vertexTCoord2.xyz, cpos, LightWorldDVector_Dir.xyz);
			lastColor.rgb = lastColor.rgb*(1.0 - cloud.a) + cloud.rgb;
			//lastColor.r = 1.0;
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
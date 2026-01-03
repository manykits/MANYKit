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
uniform vec4 User;

uniform sampler2D SampleDay;
uniform sampler2D SampleSunset;
uniform sampler2D SampleNight;

//random vector
vec3 hash33(vec3 p)
{
    // p乘以一个固定矩阵
    p = p * mat3(1111, 222.2, 333.3, 
                 444.4, 555.5, 666.6, 
                 777.7, 888.8, 999.9);
    p = -1.0 + 2.0 * fract(sin(p) * 43758.5453);
    // 随time变化，返回3维向量
    return sin(p * 3.141 + 0.05*User.x);
}

float perlinNoiseLerp(float l, float r, float t)
{
    t = ((6.0 * t - 15.0) * t + 10.0) * t * t * t;
    return mix(l, r, t);
}

float perlin_noise(vec3 p)
{
    // pi和pf（像素坐标和相对于格子的偏移）
    vec3 pi = floor(p);
    vec3 pf = fract(p);

    // 计算uvw
    vec3 uvw = pf * pf * (3.0 - 2.0 * pf);

    // 八个点ABCDEFGH=0,0,0\0,0,1\0,1,0\0,1,1\1,0,0\1,0,1\1,1,0\1,1,1
    float f000 = dot(hash33(pi + vec3(0.0, 0.0, 0.0)), pf - vec3(0.0, 0.0, 0.0));
    float f001 = dot(hash33(pi + vec3(0.0, 0.0, 1.0)), pf - vec3(0.0, 0.0, 1.0));
    float f010 = dot(hash33(pi + vec3(0.0, 1.0, 0.0)), pf - vec3(0.0, 1.0, 0.0));
    float f011 = dot(hash33(pi + vec3(0.0, 1.0, 1.0)), pf - vec3(0.0, 1.0, 1.0));
    float f100 = dot(hash33(pi + vec3(1.0, 0.0, 0.0)), pf - vec3(1.0, 0.0, 0.0));
    float f101 = dot(hash33(pi + vec3(1.0, 0.0, 1.0)), pf - vec3(1.0, 0.0, 1.0));
    float f110 = dot(hash33(pi + vec3(1.0, 1.0, 0.0)), pf - vec3(1.0, 1.0, 0.0));
    float f111 = dot(hash33(pi + vec3(1.0, 1.0, 1.0)), pf - vec3(1.0, 1.0, 1.0));

    float temp00 = perlinNoiseLerp(f000, f100, uvw.x);
    float temp01 = perlinNoiseLerp(f001, f101, uvw.x);
    float temp10 = perlinNoiseLerp(f010, f110, uvw.x);
    float temp11 = perlinNoiseLerp(f011, f111, uvw.x);

    float temp0 = perlinNoiseLerp(temp00, temp10, uvw.y);
    float temp1 = perlinNoiseLerp(temp01, temp11, uvw.y);

    float noiseValue = perlinNoiseLerp(temp0, temp1, uvw.z);

    // 去除黑边
    return noiseValue = (noiseValue + 0.5) / 2.0;
}

float fbm(vec3 p)
{
   p *= 4.;
   float a = 1., r = 0., s=0.;
    
   for (int i=0; i<4; i++)
   {
     //每次频率翻倍，强度减半
     r += a*abs(perlin_noise(p));
	 s += a; 
	 p *= 2.0; 
	 a *= 0.5;
   }
    
    return r;
}

float getCloudNoise(vec3 worldPos) {
    vec3 coord = worldPos;
    coord *= 0.006; 

	float spd_x = CloudBaseDark.w;
	float spd_y = CloudLightBright.w;
	coord.x += spd_x*0.1;
	coord.y += spd_y*0.1;
	
    float n  = fbm(coord);
		  
    return max(n - CloudLightDark.w, 0.0) * (1.0 / (1.0 - CloudLightDark.w));
}

vec4 getCloud(vec3 worldPos, vec3 cameraPos, vec3 lightDir) {
    vec3 direction = normalize(worldPos - cameraPos);   // 视线射线方向
    vec3 step = direction * CloudBaseBright.w;   // 步长
    vec4 colorSum = vec4(0);        // 积累的颜色
    vec3 pt = cameraPos;         // 从相机出发开始测试

	float dist = abs(CloudRanage.z - cameraPos.z);

	pt += direction * dist;

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
		float density = getCloudNoise(pt);                // 当前点云密度
		float lightDensity = getCloudNoise(pt - lightDir);// 向光源方向采样一次 获取密度
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
	
	vec4 skyColor = vec4(0.0, 0.0, 0.0, 1.0);
	if (LightWorldDVector_Dir.z < 0.0)
		skyColor = LerpColor(colorDay, colorSunSet, min(1.0, pow((1.0 + LightWorldDVector_Dir.z), SkyParam[1])));
	else
		skyColor = LerpColor(colorSunSet, colorNight, min(1.0, LightWorldDVector_Dir.z * 4.0));		
	vec4 lastColor = skyColor;

	float sunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[0]) * SunMoonParam[1];	
	float largeSunHighLight = pow(max(0.0, dot(camToVertex, -LightWorldDVector_Dir.xyz)), SunMoonParam[2]) * SunMoonParam[3];
	lastColor +=  SunMoonColourIn * sunHighLight + SunMoonColourOut * largeSunHighLight;
	
	if (SkyParam[2]>0)
	{
		vec3 cpos = vec3(0, 0, 0);
		vec4 cloud = getCloud(vertexTCoord2.xyz, cpos, LightWorldDVector_Dir.xyz);
		lastColor.rgb = lastColor.rgb*(1.0 - cloud.a) + cloud.rgb;
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
#version 330 core

layout (location = 0) out vec4 pixelColor;

in vec2 vertexTCoord0;
uniform sampler2D SampleBase;
uniform vec4 Control;

void main()
{
	vec2 uv = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);
	
	vec4 baseColor = texture2D(SampleBase, uv);
	
	const float gamma = 2.2;
    vec3 hdrColor = baseColor.rgb;
    if(Control.x > 0.0)
    {
        // reinhard
        //vec3 result = hdrColor / (hdrColor + vec3(1.0));
        // exposure
        vec3 result = vec3(1.0) - exp(-hdrColor * Control.y);
        // also gamma correct while we're at it

        result = pow(result, vec3(1.0 / gamma));
        pixelColor = vec4(result, 1.0);
    }
    else
    {
        vec3 result = pow(hdrColor, vec3(1.0 / gamma));
        pixelColor = vec4(result, 1.0);
    }
}
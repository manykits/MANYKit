varying mediump vec2 vertexTCoord0;
uniform mediump vec4 UVParam;
uniform mediump vec4 Control;
uniform sampler2D SampleBase;
void main()
{
	mediump vec2 uv = vec2(vertexTCoord0.x, 1.0-vertexTCoord0.y);	
	mediump vec4 lastcolor = texture2D(SampleBase, uv) * 0.2270270270;
	
	mediump vec2 tex_offset = 1.0 / vec2(UVParam.x, UVParam.y);
	
	mediump vec2 uvoffset;
	
	uvoffset = vec2(tex_offset.x * 1.0 * Control.x, tex_offset.y * 1.0 * (1.0-Control.x));
	lastcolor += texture2D(SampleBase, uv + uvoffset) * 0.1945945946;
	lastcolor += texture2D(SampleBase, uv - uvoffset) * 0.1945945946;
	
	uvoffset = vec2(tex_offset.x * 2.0 * Control.x, tex_offset.y * 2.0 * (1.0-Control.x));
	lastcolor += texture2D(SampleBase, uv + uvoffset) * 0.1216216216;
	lastcolor += texture2D(SampleBase, uv - uvoffset) * 0.1216216216;
	
	uvoffset = vec2(tex_offset.x * 3.0 * Control.x, tex_offset.y * 3.0 * (1.0-Control.x));
	lastcolor += texture2D(SampleBase, uv + uvoffset) * 0.0540540541;
	lastcolor += texture2D(SampleBase, uv - uvoffset) * 0.0540540541;
	
	uvoffset = vec2(tex_offset.x * 4.0 * Control.x, tex_offset.y * 4.0 * (1.0-Control.x));
	lastcolor += texture2D(SampleBase, uv + uvoffset) * 0.0162162162;
	lastcolor += texture2D(SampleBase, uv - uvoffset) * 0.0162162162;
	
	gl_FragColor = lastcolor;
}
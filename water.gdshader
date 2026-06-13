shader_type spatial;
uniform sampler2D water_normal_noise;
uniform float time_scale:hint_range(0,10,0.25)=1.0;
uniform vec3 water_colour:source_color;
uniform sampler2D screen_texture:hint_screen_texture;
void fragment() {
	
	vec2 _uv=UV;
	_uv.x+=sin(TIME*time_scale+(_uv.x+_uv.y)*0.0005)*0.001;
	_uv.y+=cos(TIME*time_scale+(_uv.x-_uv.y)*0.0005)*0.001;
	ALBEDO=texture(screen_texture,SCREEN_UV).rgb;
	NORMAL_MAP=texture(water_normal_noise,_uv).rgb;
	NORMAL *= 0.5;
	ROUGHNESS=0.2;
}
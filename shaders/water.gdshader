shader_type spatial;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform vec3 water_color : source_color = vec3(0.167, 0.406, 0.618);
uniform vec3 submerged_obj_color : source_color = vec3(0.084, 0.203, 0.309);
uniform float murkiness : hint_range(0.0, 1.0) = 0.5;
uniform float foam_intensity : hint_range(1.0, 30.0) = 15.0;
uniform float ripple_length : hint_range(0.0, 1.0) = 0.25;

void fragment()
{
	float depth = texture(depth_texture, SCREEN_UV).r; // reverse-z near-to-far depth buffer
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec4 depth_ndc = vec4(SCREEN_UV, depth) * 2.0 - 1.0, 1.0);
	#else
	vec4 depth_ndc = vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	#endif
	vec4 depth_view_space = INV_PROJECTION_MATRIX * depth_ndc;
	depth_view_space.xyz /= depth_view_space.w;
	float water_depth = abs(depth_view_space.z - VERTEX.z);
	
	float submerged_mask = water_depth * water_depth * murkiness;
	submerged_mask = clamp(submerged_mask, 0.0, 5.0) * 0.2;
	vec3 submerged_color = submerged_mask * water_color + (1.0 - submerged_mask) * submerged_obj_color;
	
	float foam = clamp(water_depth, 0.0, 1.0);
	foam = 1.0 - foam;
	foam = pow(foam, foam_intensity);
	
	float ripple = clamp(water_depth, 0.0, ripple_length) / ripple_length;
	ripple = 1.0 - ripple;
	float sin_wave = abs(sin((TIME * 0.5 + ripple) * 4.0));
	sin_wave = 1.0 - sin_wave;
	if (sin_wave > 0.5)
	{
		sin_wave = 1.0;
	}
	else
	{
		sin_wave = 0.0;
	}
	float total_wave = clamp(sin_wave * ripple + foam, 0.0, 1.0); 
	
	ALBEDO = (1.0 - total_wave) * submerged_color + total_wave;
}
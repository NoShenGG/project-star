shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_back, unshaded;

uniform sampler2D albedo_mask : filter_linear_mipmap_anisotropic;
uniform vec4 basse_color : source_color = vec4(1, 1, 1, 1);
uniform sampler2D emission_mask : filter_linear_mipmap_anisotropic;
uniform float emission_str;
uniform vec4 emission_color : source_color = vec4(1, 1, 1, 1);


void vertex() {
	// Billboard Mode: Particles
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]),
			normalize(INV_VIEW_MATRIX[2]),
			MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}


void fragment() {

	vec4 albedo_texture = texture(albedo_mask, UV) * basse_color * COLOR;

	vec4 emission_texture = (texture(emission_mask, UV) * vec4(emission_str)) * emission_color;


	vec3 result = (vec3(albedo_texture.rgb)) + (vec3(emission_texture.rgb));
	//  non-inverse screening
	//vec3 result = (vec3(albedo_texture.rgb)) * (vec3(emission_texture.rgb));
	//  screen
	//vec3 result = vec3(1.0) - (vec3(1.0) - vec3(albedo_texture.rgb)) * (vec3(1.0) - vec3(emission_texture.rgb));

	ALBEDO = result;
	ALPHA = albedo_texture.a;


}

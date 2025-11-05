shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_disabled, unshaded;

uniform sampler2D albedo_mask : filter_linear_mipmap_anisotropic;
uniform vec4 basse_color : source_color = vec4(1, 1, 1, 1);
uniform sampler2D emission_mask : filter_linear_mipmap_anisotropic;
uniform float emission_str;
uniform vec4 emission_color : source_color = vec4(1, 1, 1, 1);


void vertex() {
	// Billboard Keep Scale: Enabled
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

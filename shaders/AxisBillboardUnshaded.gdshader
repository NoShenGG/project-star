// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx,unshaded;


uniform vec4 albedo : source_color = vec4(1, 1, 1, 1);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_emission : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color = vec4(1, 1, 1, 1);
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);

uniform vec3 uv1_scale = vec3(1,1,1);
uniform vec3 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	vec3 cam_origin = INV_VIEW_MATRIX[3].xyz;
	vec3 spr_origin = MODEL_MATRIX[3].xyz;

	vec3 basis_z = normalize(cam_origin - spr_origin);
	vec3 basis_y = MODEL_MATRIX[2].xyz;
	vec3 basis_x = normalize(cross(basis_y, basis_z));

	mat4 new_mat = MODEL_MATRIX;
	new_mat[0].xyz = basis_x ;//* length(MODEL_MATRIX[0].xyz);
	new_mat[1].xyz = basis_y;
	new_mat[2].xyz = basis_z;

	MODELVIEW_MATRIX = VIEW_MATRIX * new_mat;
}

void fragment() {

	vec4 albedo_texture = texture(texture_albedo, UV) * albedo * COLOR;

	vec4 emission_texture = (texture(texture_emission, UV) * vec4(emission_energy)) * emission;


	vec3 result = (vec3(albedo_texture.rgb)) + (vec3(emission_texture.rgb));
	//  non-inverse screening
	//vec3 result = (vec3(albedo_texture.rgb)) * (vec3(emission_texture.rgb));
	//  screen
	//vec3 result = vec3(1.0) - (vec3(1.0) - vec3(albedo_texture.rgb)) * (vec3(1.0) - vec3(emission_texture.rgb));

	ALBEDO = result;
	ALPHA = albedo_texture.a;


}

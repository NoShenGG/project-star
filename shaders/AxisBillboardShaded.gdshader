// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;


uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_emission : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
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
	vec2 base_uv = UV;
	
	vec4 albedo_tex = texture(texture_albedo, base_uv) * COLOR;
	
	// Vertex Color Use as Albedo: Enabled
	albedo_tex *= COLOR;
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	// Emission: Enabled
	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	// Emission Operator: Add
	EMISSION = (emission.rgb + emission_tex) * COLOR.rgb * emission_energy;
	ALPHA *= albedo.a * albedo_tex.a;
}

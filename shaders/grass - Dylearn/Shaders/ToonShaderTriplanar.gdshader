// MIT License.
// Made by Dylearn
// Adapted from atzuk4451 https://godotshaders.com/shader/flexible-toon-shader-godot-4/

shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture;

uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

varying vec3 normal;
varying vec3 vertex_world;


varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness : hint_range(1.0, 150.0, 0.001);
varying vec3 uv1_power_normal;

uniform float uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

group_uniforms red_material;
group_uniforms red_material.textures;
uniform sampler2D albedo_r : source_color;

uniform sampler2D height_base : source_color, filter_linear_mipmap_anisotropic;

group_uniforms red_material.settings;
uniform vec4 modulate_r : source_color = vec4(1.0);
uniform sampler2D vertex_color_curve_r : repeat_disable, hint_default_black;
uniform sampler2D height_curve_r : repeat_disable, hint_default_black;

#include "uid://cse0e4sjc6k8h"

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void vertex() {
	normal = NORMAL;
	vertex_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec3 triplanar_normal = MODEL_NORMAL_MATRIX * NORMAL;

	TANGENT = vec3(0.0, 0.0, -1.0) * abs(triplanar_normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(triplanar_normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(triplanar_normal.z);
	TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);
	
	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(triplanar_normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(triplanar_normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(triplanar_normal.z);
	BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);
	
	// UV1 Triplanar: Enabled (with World Triplanar)
	uv1_power_normal = pow(abs(triplanar_normal), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

float burn(float a, float b) {
	return 1.0 - (1.0 - a) / b;
}

float map_curve(float value, sampler2D curve_texture) {
	return texture(curve_texture, vec2(value, 0.0)).r;
}

void fragment() {
	
	
	vec4 main_tex = triplanar_texture(albedo_texture, uv1_power_normal, uv1_triplanar_pos);
	ALBEDO = albedo.rgb * main_tex.rgb;
	
	float mask = clamp(burn(
		map_curve(COLOR.r, vertex_color_curve_r),
		map_curve(texture(height_base, UV).r, height_curve_r)
	), 0.0, 1.0);

	// Red channel material
	ALBEDO = mix(ALBEDO, triplanar_texture(albedo_r, uv1_power_normal, uv1_triplanar_pos).rgb * modulate_r.rgb, mask);
}

void light() {
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (ATTENUATION - 1.0) + wrap;
	diffuse_amount *= steepness;

	// CLOUDS
	if (LIGHT_IS_DIRECTIONAL) {
		float light_value = get_cloud_noise(vertex_world);
		diffuse_amount = min(diffuse_amount, light_value);
	}

	// Toon Shading
	float cuts_inv = 1.0f / float(cuts);
	float cut = cuts_inv; // single cut width
	float original_index = ceil(diffuse_amount * float(cuts));   // ceil(diffuse * cuts)
	float original_stepped = clamp(original_index * cut, 0.0, 1.0);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);

	diffuse_stepped = original_stepped;
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	diffuse *= diffuse_stepped;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
}
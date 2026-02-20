// MIT License.
// Made by Dylearn
// Adapted from atzuk4451 https://godotshaders.com/shader/flexible-toon-shader-godot-4/

shader_type spatial;

group_uniforms colour;
uniform vec4 albedo1 : source_color = vec4(1.0f);

group_uniforms colour.albedo2;
uniform vec4 albedo2 : source_color = vec4(1.0f);
uniform sampler2D albedo2_noise;
uniform float albedo2_scale : hint_range(0.0, 1.0, 0.001) = 0.005;
uniform float albedo2_threshold : hint_range(0.0, 1.0, 0.001) = 0.604;

group_uniforms colour.albedo3;
uniform vec4 albedo3 : source_color = vec4(1.0f);
uniform sampler2D albedo3_noise;
uniform float albedo3_scale : hint_range(0.0, 0.1, 0.001) = 0.003;
uniform float albedo3_threshold : hint_range(0.0, 1.0, 0.001) = 0.661;

group_uniforms lighting;
uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

varying vec3 vertex_pos;
varying vec3 normal;
varying vec3 vertex_world;

#include "uid://cse0e4sjc6k8h"

void vertex() {
	vertex_pos = VERTEX;
	normal = NORMAL;
	vertex_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Texture noises for grass patches
	float albedo2_noise_tex = texture(albedo2_noise, vertex_world.xz * (albedo2_scale)).r;
	float albedo3_noise_tex = texture(albedo3_noise, vertex_world.xz * (albedo3_scale)).r;
	// Set colours based on noise thresholds
	ALBEDO = albedo1.rgb;
	if (albedo2_noise_tex > albedo2_threshold) {
		ALBEDO = albedo2.rgb;
	} if (albedo3_noise_tex > albedo3_threshold) {
		ALBEDO = albedo3.rgb;
	}
}

void light() {
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (ATTENUATION - 1.0) + wrap;
	diffuse_amount *= steepness;

	// CLOUDS
	if (LIGHT_IS_DIRECTIONAL) {
		vec3 vertex_world_pos = (MODEL_MATRIX * vec4(vertex_pos, 1.0)).xyz;
		float light_value = get_cloud_noise(vertex_world_pos);
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
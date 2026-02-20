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

#include "uid://cse0e4sjc6k8h"

void vertex() {
	normal = NORMAL;
	vertex_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
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
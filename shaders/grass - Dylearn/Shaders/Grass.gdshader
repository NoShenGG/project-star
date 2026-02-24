// MIT License.
// Made by Dylearn

shader_type spatial;
render_mode depth_prepass_alpha, depth_draw_opaque; //, cull_disabled;

#include "uid://cse0e4sjc6k8h"

group_uniforms colours_and_textures;
uniform sampler2D albedo_texture : source_color, filter_nearest; // Sprite for main grass quad
uniform vec4 albedo1 : source_color = vec4(1.0f); // Colour for main grass quad

	group_uniforms colours_and_textures.albedo2;
uniform vec4 albedo2 : source_color = vec4(1.0f); // Colour for grass patch 2
uniform float albedo2_scale : hint_range(0.0, 1.0, 0.001) = 0.005; // Scale for grass patch 2 noise
uniform float albedo2_threshold : hint_range(0.0, 1.0, 0.001) = 0.604; // Threshold for grass patch 2 noise
uniform sampler2D albedo2_noise; // Noise pattern for grass patch 2

	group_uniforms colours_and_textures.albedo3;
uniform vec4 albedo3 : source_color = vec4(1.0f); // Colour for grass patch 3
uniform float albedo3_scale : hint_range(0.0, 0.1, 0.001) = 0.003; // Scale for grass patch 3 noise
uniform float albedo3_threshold : hint_range(0.0, 1.0, 0.001) = 0.661; // Threshold for grass patch 3 noise
uniform sampler2D albedo3_noise; // Noise pattern for grass patch 3

	group_uniforms colours_and_textures.accent1;
uniform float accent_frequency1 : hint_range(0.0, 0.05, 0.0001) = 0.001; // Frequency of accent grass 1
uniform sampler2D accent_texture1 : source_color, filter_nearest; // Sprite for accent grass 1
uniform vec4 accent_albedo1 : source_color = vec4(1.0f); // Colour for accent grass 1
uniform float accent_height1 : hint_range(0.0, 1.0, 0.001) = 0.5; // Height for accent grass 1
uniform float accent_scale1 : hint_range(0.0, 2.0, 0.001) = 1.0; // Scale (xy) for accent grass 1

	group_uniforms colours_and_textures.accent2;
uniform float accent_probability2 : hint_range(0.0, 0.05, 0.0001) = 0.1; // Frequency of accent grass 2
uniform sampler2D accent_texture2 : source_color, filter_nearest; // Sprite for accent grass 2
uniform vec4 accent_albedo2 : source_color = vec4(1.0f); // Colour for accent grass 2
uniform float accent_height2 : hint_range(0.0, 1.0, 0.001) = 0.5; // Height for accent grass 2
uniform float accent_scale2 : hint_range(0.0, 2.0, 0.001) = 1.0; // Scale (xy) for accent grass 2


group_uniforms animation;
uniform float framerate = 5.0; // Framerate for worldspace and viewspace grass rotation
uniform bool quantised = true; // Toggle quantised framerate
	group_uniforms animation.world_space;
uniform bool world_space_sway = true; // Toggle world space rotation
uniform bool debug_noise = false; // Toggle colour debugging for world space rotation
uniform float world_sway_angle : hint_range(0.0f, 180.0f) = 60.0; // Maximum angle of swaying in degrees
uniform float fake_perspective_scale : hint_range(-0.15, 0.6, 0.001) = 0.3; // Intensity of fake perspective effect
uniform sampler2D wind_noise; // Noise for world space rotation
uniform float wind_noise_threshold : hint_range(-1.0, 1.0, 0.001) = 0.365; // Brightness of wind noise (see debug mode)
uniform float wind_noise_scale : hint_range(0.0, 0.1, 0.001) = 0.071; // Scale of wind noise (see debug mode)
uniform float wind_noise_speed : hint_range(0.0, 0.2, 0.001) = 0.025; // Speed of wind noise movement (see debug mode)
uniform vec2 wind_noise_direction = vec2(0.0, 1.0); // Worldspace xz direction of wind (see debug mode)
uniform float noise_diverge_angle : hint_range(0.0, 45.0, 0.001) = 10.0; // Angle at which the two noises split from each other
	group_uniforms animation.view_space;
uniform bool view_space_sway = true; // Toggle viewspace rotation
uniform float view_sway_speed : hint_range(0.0f, 5.0f) = 0.1; // Speed of swaying in cycles per second
uniform float view_sway_angle : hint_range(0.0f, 45.0f) = 10.0; // Maximum angle of swaying in degrees
	group_uniforms character_displacement;
uniform bool character_displacement = true; // Toggle character based displacement rotation
uniform bool debug_displacement = false; // Toggle colour debugging for rotation
uniform vec4 tint_displacement : source_color = vec4(1.0f); // Toggle colour debugging for rotation
uniform float tint_weight : hint_range(0.0, 1, 0.01) = 0; // Toggle colour debugging for rotation

uniform float player_displacement_angle_z : hint_range(0.0, 360.0, 0.1) = 45.0; // Maximum degrees of rotation around viewspace z axis
uniform float player_displacement_angle_x : hint_range(0.0, 360.0, 0.1) = 45.0;// MAximum degrees of rotation around viewspace x axis
uniform float radius_exponent : hint_range(0.0, 10.0, 0.001) = 1.0; // Steepness of displacement mask
const int character_count = 64; // Size of array holding character information
uniform vec4[character_count] character_positions; // Array holding character positions and sizes

group_uniforms lighting;
uniform int cuts : hint_range(1, 8) = 3; // Number of lighting cuts in toon shader
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f; // Bias lighting
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f; // Steepness of lighting
uniform float threshold_gradient_size = 0.2; // Hybrid toon shading control (set to 0 for standard toon shading)

varying float debug_wind_color;
varying vec3 debug_interactive_color;
varying float wind_noise_sample;

varying float instance_id;
varying float id_seed1;
varying float id_seed2;

varying vec3 model_origin;
varying vec3 object_origin;
varying vec3 world_pos;

varying float player_displacement_fake_perspective;

float location_seed (vec2 location) { // Random value based on world space location
	return fract(sin(dot(location, vec2(12.9898,78.233))) * 43758.5453123);
}

float random(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

mat4 rotateAroundAxis(vec3 axis, float angle) {
	axis = normalize(axis);
	float c = cos(angle);
	float s = sin(angle);
	float oc = 1.0 - c;

	mat4 rotation = mat4(
		vec4(oc * axis.x * axis.x + c,
		oc * axis.x * axis.y - axis.z * s,
		oc * axis.z * axis.x + axis.y * s,
		0.0),

		vec4(oc * axis.x * axis.y + axis.z * s,
		oc * axis.y * axis.y + c,
		oc * axis.y * axis.z - axis.x * s,
		0.0),

		vec4(oc * axis.z * axis.x - axis.y * s,
		oc * axis.y * axis.z + axis.x * s,
		oc * axis.z * axis.z + c,
		0.0),

		vec4(0.0, 0.0, 0.0, 1.0)
	);
	return rotation;
}

mat4 view_space_rotate(float angle) {
	return mat4(
		vec4(cos(angle), -sin(angle), 0.0, 0.0),
		vec4(sin(angle), cos(angle), 0.0, 0.0),
		vec4(0.0, 0.0, 1.0, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
}

void vertex() {
	instance_id = float(INSTANCE_ID);
	// Generate random numbers for accent leaves based on instance ID
	id_seed1 = random(instance_id);
	id_seed2 = random(instance_id + PI);
	//// Accent 1
	if (id_seed1 < accent_frequency1) {
		VERTEX.y += accent_height1;
		VERTEX *= accent_scale1;
	}
	// Accent 2
	else if (id_seed2 < accent_probability2) {
		VERTEX.y += accent_height2;
		VERTEX *= accent_scale2;
	}
	// Get vertex world position
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// Find origin of each quad of grass in world-space
	object_origin = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

	// Generate a random seed based on the objects world position
	float seed = 10.0 * location_seed(object_origin.xy);
	// Calculate time between frames
	float frametime = 1.0 / framerate;
	// Calculate randomised phase of framerate for each quad based on the world position
	// This so they don't all update on the same frame as that would just look laggy
	float phase = mod(seed, frametime);

	float time = TIME;
	if (quantised) {
		// Offset framerate update based on objects unique phase
		time += phase;
		// Quantise the time to create a stepped framerate
		time = round(time * framerate) / framerate;
	}
	// Rotate wind noise direction left and right
	vec2 wind_noise_direction1 = rotate_vec2(wind_noise_direction, noise_diverge_angle);
	vec2 wind_noise_direction2 = rotate_vec2(wind_noise_direction, -noise_diverge_angle);
	// Scroll noises using time
	vec2 wind_noise_time_direction1 = time * wind_noise_speed * normalize(wind_noise_direction1);
	vec2 wind_noise_time_direction2 = time * wind_noise_speed * normalize(wind_noise_direction2);
	// Sample noise value (change speed and scale of 2nd one to avoid obvious repeating of texture)
	float wind_noise_sample1 = texture(wind_noise, object_origin.xz * wind_noise_scale + wind_noise_time_direction1).r;
	float wind_noise_sample2 = texture(wind_noise, object_origin.xz * (wind_noise_scale * 0.8) + (wind_noise_time_direction2 * 0.89 * PI / 3.0)).r;
	// Combine noise samples
	wind_noise_sample = (wind_noise_sample1 * wind_noise_sample2);
	wind_noise_sample = clamp(wind_noise_sample + wind_noise_threshold, 0.0, 1.0);
	// Scale noise sample between -1.0 --> 1.0
	wind_noise_sample = (wind_noise_sample - 0.5) * 2.0;

	// Calculate world space rotation angle based on noise
	float world_sway = wind_noise_sample * radians(world_sway_angle);
	// Calculate axis perpendicular to wind direction
	vec3 wind_world_axis = (vec4(wind_noise_direction.y, 0.0, -wind_noise_direction.x, 1.0) * INV_VIEW_MATRIX).xyz;
	// Rotate around that axis in world space
	mat4 world_rotation = rotateAroundAxis(wind_world_axis, world_sway);

	// Calculate model space rotation angle
	float model_sway = sin((time + seed) * view_sway_speed * 2.0 * PI) * radians(view_sway_angle);
	//Define quad roration based on sway calc (around camera z axis)
	mat4 model_rotation = view_space_rotate(model_sway);

	// Calculate character displacement rotation
	// Define displacement variables that will be cumulatively added to inside of loop
	float character_displacement_x = 0.0;
	float character_displacement_y = 0.0;
	// Calculate each character_position's influence on rotation, and add the values cumulatively
	for (int i=0; i < character_count; i++) {
		// Find distance between grass origin and character and scale radius based on character size value
		float distance = length(character_positions[i].xyz - object_origin) / character_positions[i].w;
		// Calculate strength and steepness of displacement
		float displacement_strength = pow(1.0 - distance, radius_exponent);

		// If a character is displacing the grass
		if (displacement_strength > 0.0) {
			// Clamp displacement influence
			displacement_strength = clamp(displacement_strength, 0.0, 1.0);

			// Get direction from character to grass in world space
			vec3 character_to_grass = object_origin - character_positions[i].xyz;


			// Calculate how much to scale rotation in screen y axis based on alignment to camera's forward vector
			float view_y_dot = dot(normalize(CAMERA_DIRECTION_WORLD.xz), normalize(character_to_grass.xz)); //-1.0 on top, 1.0 on bottom
			// Same for x axis but using perpendicular vector
			vec3 perpendicular_camera_direction_world = vec3(CAMERA_DIRECTION_WORLD.z, 0.0, -CAMERA_DIRECTION_WORLD.x); //1.0 on right, -1.0 on left
			float view_x_dot = dot(normalize(perpendicular_camera_direction_world.xz), normalize(character_to_grass.xz));

			// Cumulatively add together influences from each character
			character_displacement_x += displacement_strength * view_x_dot;
			character_displacement_y += displacement_strength * view_y_dot;
			}
		}
	// Clamp values to stop overrotating
	character_displacement_x = clamp(character_displacement_x, -1.0, 1.0);
	character_displacement_y = clamp(character_displacement_y, -1.0, 1.0);

	// Save color for debugging
	debug_interactive_color = vec3(
		character_displacement_x + character_displacement_y,
		-character_displacement_x + character_displacement_y,
		-character_displacement_y
		);

	// Combine rotation around camera z and camera x axis
	mat4 player_displacement_rotation =
		// Rotate left/right around viewspace z
		rotateAroundAxis(vec3(0.0, 0.0, 1.0), character_displacement_x * radians(player_displacement_angle_z))
		// Rotate forward/backward around viewspace x
		* rotateAroundAxis(vec3(1.0, 0.0, 0.0), character_displacement_y * radians(player_displacement_angle_x));
	// Send fake perspective strength to varying
	player_displacement_fake_perspective = character_displacement_y;

	// Apply rotations to vertex position
	if (view_space_sway) {
		VERTEX = (model_rotation * vec4(VERTEX, 1.0)).xyz;
	}
	if (character_displacement) {
		VERTEX = (player_displacement_rotation * vec4(VERTEX, 1.0)).xyz;
	}
	if (world_space_sway) {
		VERTEX = (world_rotation * vec4(VERTEX, 1.0)).xyz;
		//// UV SQUISHING DOESN'T WORK WELL ON VERTICES
		//float t = 1.0 - UV.y;
		//float world_sway_factor = dot(CAMERA_DIRECTION_WORLD.xz, wind_noise_direction);
		//VERTEX.x *= mix(1.0, ((world_sway * -top_scale * world_sway_factor) + 1.0), t);
	}

	// billboard quads to face camera
	mat4 modified_model_view = VIEW_MATRIX * mat4(
		vec4(INV_VIEW_MATRIX[0].xyz, 0.0),
		vec4(INV_VIEW_MATRIX[1].xyz, 0.0),
		vec4(INV_VIEW_MATRIX[2].xyz, 0.0),
		MODEL_MATRIX[3]
	);

	// Save model origin for lighting
	model_origin = (MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	MODELVIEW_MATRIX = modified_model_view;
	// Save noise sample for debugging
	debug_wind_color = wind_noise_sample;
}

void fragment() {
	vec2 uv = UV;
	// Scale UV.x around centre
	uv.x -= 0.5;
	// Get noise value and scale appropriately
	float _wind_noise_sample = (wind_noise_sample) * fake_perspective_scale;
	if (world_space_sway) {
	// Scale effect based on how camera aligns with wind (no fake perspective when perpendicular)
	_wind_noise_sample *= dot(CAMERA_DIRECTION_WORLD.xz, wind_noise_direction);
	// Scale UV.x proportionally in the vertical axis
	uv.x *= (1.0 - uv.y) * _wind_noise_sample + 1.0;
	}
	if (character_displacement) {
	// Scale UV.x proportionally based on character displacement
	uv.x *= (1.0 - uv.y) * -player_displacement_fake_perspective + 1.0;
	}
	// Convert back to normal after scaling
	uv.x += 0.5;
	// Clamp UV to stop tiling
	uv.x = clamp(uv.x, 0.0, 1.0);


	// Sample albedo texture based on above calculation
	vec4 albedo_tex = texture(albedo_texture, uv);
	float albedo2_noise_tex = texture(albedo2_noise, object_origin.xz * (albedo2_scale)).r;
	float albedo3_noise_tex = texture(albedo3_noise, object_origin.xz * (albedo3_scale)).r;
	ALBEDO = albedo1.rgb * albedo_tex.rgb;
	if (albedo2_noise_tex > albedo2_threshold) {
		ALBEDO = albedo2.rgb;
	} if (albedo3_noise_tex > albedo3_threshold) {
		ALBEDO = albedo3.rgb;
	}
	// Accent 1
	if (id_seed1 < accent_frequency1) {
		albedo_tex = texture(accent_texture1, uv);
		ALBEDO = accent_albedo1.rgb * albedo_tex.rgb;
	}
	// Accent 2
	else if (id_seed2 < accent_probability2) {
		albedo_tex = texture(accent_texture2, uv);
		ALBEDO = accent_albedo2.rgb * albedo_tex.rgb;
	}
	ALBEDO = mix(ALBEDO.rgb, tint_displacement.rgb, min(length(debug_interactive_color), 1) * tint_weight);

	LIGHT_VERTEX = model_origin;
	ALPHA = albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 1.0;
	//ALBEDO = vec3(UV.y);
	if (debug_noise) {
		ALBEDO = vec3(debug_wind_color);
	}
	if (debug_displacement) {
	//ALBEDO = vec3(distance1, -distance1, distance1);
	ALBEDO = vec3(debug_interactive_color);
	}
}

void light() {
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (ATTENUATION - 1.0) + wrap;
	diffuse_amount *= steepness;

	// CLOUDS
	if (LIGHT_IS_DIRECTIONAL) {
		vec3 vertex_world_pos = (INV_VIEW_MATRIX * vec4(model_origin, 1.0)).xyz;
		float light_value = get_cloud_noise(vertex_world_pos);
		diffuse_amount = min(diffuse_amount, light_value);
	}

	// Toon Shading
	float cuts_inv = 1.0f / float(cuts);
	float cut = cuts_inv; // single cut width
	float original_index = ceil(diffuse_amount * float(cuts));   // ceil(diffuse * cuts)
	float original_stepped = clamp(original_index * cut, 0.0, 1.0);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);

	// Hybrid Toon Shading
	if (threshold_gradient_size > 0.0) {
		// Find nearest threshold (k * cut). We use rounding so the threshold chosen is the boundary that the original hard-step used around this value.
		float nearest_k = floor(diffuse_amount / cut + 0.5); // round to nearest integer
		float threshold = nearest_k * cut;

		// Do not create gradients at the global edges (threshold==0 or threshold==1)
		if (nearest_k >= 0.0 && nearest_k <= float(cuts)) {
			float halfWidth = 0.5 * cut * threshold_gradient_size;

			// Clamp gradient low/high so they stay inside 0 to 1
			float low  = max(0.0, threshold - halfWidth);
			float high = min(1.0, threshold + halfWidth);

			float blend = 0.0;
			if (high > low) {
				blend = smoothstep(low, high, diffuse_amount);
			} else {
				blend = step(threshold, diffuse_amount);
			}

			// define which cut colours/lighting you take for upper and lower boundary
			float leftValue  = threshold;
			float rightValue = min(threshold + (cut * 1.0), 1.0);
			diffuse_stepped = mix(leftValue, rightValue, blend);
			diffuse_stepped = clamp(diffuse_stepped, 0.0, 1.0);
		} else {
			diffuse_stepped = original_stepped;
		}
	}
	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	diffuse *= diffuse_stepped;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
}
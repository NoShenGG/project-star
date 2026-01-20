shader_type spatial;
render_mode unshaded, blend_add;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool use_second_color = false;
uniform vec4 second_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cone_start_width : hint_range(0.0, 1.0, 0.01) = 0.02;
uniform float cone_curve : hint_range(0, 1.0, 0.01) = 0.3;
uniform float beam_sharpness : hint_range(0.01, 1.0, 0.01) = 0.25;
uniform float beam_fade : hint_range(0.1, 10.0, 0.1) = 4.0;
uniform bool use_gradient = false;
uniform sampler2D gradient: source_color, repeat_disable;
uniform float proximity_fade_distance : hint_range(0.0, 4096.0, 0.01) = 0.75;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float z_fade_start : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float z_fade_end : hint_range(0.0, 1.0, 0.01) = 0.8;

uniform bool use_noise = false;
uniform sampler2D noise_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform float noise_scale : hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float noise_intensity : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec2 noise_scroll_speed = vec2(0.01, 0.01);
uniform float noise_distortion_intensity : hint_range(0.0, 0.1, 0.001) = 0.01;
uniform vec2 noise_distortion_scroll_speed = vec2(-0.02, -0.01);

varying float z_axis_fade;

void vertex() {
	vec3 local_z = normalize(MODEL_MATRIX[2].xyz);
	vec3 to_camera = normalize(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD);
	vec3 local_x = normalize(cross(to_camera, local_z));
	vec3 local_y = normalize(cross(local_z, local_x));
	
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(local_x * length(MODEL_MATRIX[0].xyz), 0.0),
		vec4(local_y * length(MODEL_MATRIX[1].xyz), 0.0),
		MODEL_MATRIX[2],
		MODEL_MATRIX[3]
	);

	z_axis_fade = smoothstep(z_fade_end, z_fade_start, abs(dot(to_camera, local_z)));
}

void fragment() {
	vec2 uv = UV;

	vec3 input_color;
	float input_alpha;
	if (use_second_color) {
		input_color = mix(color.rgb, second_color.rgb, uv.y);
		input_alpha = mix(color.a, second_color.a, uv.y);
	} else {
		input_color = color.rgb;
		input_alpha = color.a;
	}
	
	// Calculate cone width at current position along the cone length
	float cone_progress_y = pow(uv.y, 1.0 - cone_curve);
	float width = mix(cone_start_width, 1.0, cone_progress_y);
	float half_width = width * 0.5;
	
	// Create horizontal mask
	float distance_from_center_x = abs(uv.x - 0.5);
	float beam_edge_start = half_width - (half_width * (1.0 - beam_sharpness));
	float horizontal_mask = 1.0 - smoothstep(beam_edge_start, half_width, distance_from_center_x);	

	// Create vertical mask
	float vertical_mask = pow(max(1.0 - uv.y, 0.001), beam_fade);
	vertical_mask *= smoothstep(0.0, cone_start_width * 0.5, uv.y);

	// Overlay gradient
	if (use_gradient) {
		float gradient_coord = distance_from_center_x / half_width;
		float gradient_value = texture(gradient, vec2(gradient_coord, 0.5)).r;
		horizontal_mask *= mix(1.0, gradient_value, 1.0 - (vertical_mask * vertical_mask));
	}
	
	// Overlay noise
	if (use_noise) {
		vec2 distortion_offset = noise_distortion_scroll_speed * TIME + NODE_POSITION_WORLD.xz;
		vec2 distortion_sample = texture(noise_texture, uv * noise_scale + distortion_offset).rg;
		vec2 distortion_uv = uv + (distortion_sample - 0.5) * 2.0 * noise_distortion_intensity;

		vec2 scroll_offset1 = noise_scroll_speed * TIME + NODE_POSITION_WORLD.xz;
		vec2 scroll_offset2 = vec2(-noise_scroll_speed.x * 0.7, noise_scroll_speed.y * 1.3) * TIME + NODE_POSITION_WORLD.xz;
		
		float noise_sample1 = texture(noise_texture, distortion_uv * noise_scale + scroll_offset1).r;
		float noise_sample2 = texture(noise_texture, distortion_uv * noise_scale + scroll_offset2).r;
		float combined_noise = mix(1.0, noise_sample1 * noise_sample2, 1.0 - vertical_mask);

		horizontal_mask *= mix(1.0, combined_noise, noise_intensity);
	}

	ALBEDO = input_color;

	ALPHA = horizontal_mask * vertical_mask * input_alpha * z_axis_fade;

	// Proximity Fade
	float proximity_depth_tex = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 proximity_view_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, proximity_depth_tex, 1.0);
	proximity_view_pos.xyz /= proximity_view_pos.w;
	ALPHA *= clamp(1.0 - smoothstep(proximity_view_pos.z + proximity_fade_distance, proximity_view_pos.z, VERTEX.z), 0.0, 1.0);
}
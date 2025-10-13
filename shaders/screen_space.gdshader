shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform float grain_size : hint_range(0.1, 10.0) = 1.0; // Adjust the size of the grain
uniform bool animate = false;

uniform float blur_radius : hint_range(0, 1) = 0.2; // Radius of the blur effect
uniform float blur_amount : hint_range(0, 5) = 1.0; // Strength of the blur effect
uniform float blur_inner : hint_range(0, 1) = 0.6; // Inner edge of the blur effect
uniform float blur_outer : hint_range(0, 1) = 0.66; // Outer edge of the blur effect

void fragment() {
	//FILM GRAIN START
	// Sample the original screen texture
	vec4 original_color = texture(screen_texture, SCREEN_UV);
	
	float noise = 0.0;
	
	if (animate) {
		// Generate random noise
		noise = (fract(sin(dot(UV * TIME, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
	} else {
		 noise = (fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
	}
	// Add noise to the original color
	original_color.rgb += noise * grain_amount * grain_size;
	//FILM GRAIN END
	
	// BLUR START
	// Original color of the pixel from the screen
    vec4 pixelColor = texture(screen_texture, UV);
    
    // Color with blur effect from the screen
    vec4 blurColor = textureLod(screen_texture, SCREEN_UV, blur_amount);

    // Calculate distance from the center of the screen
    float distance = length(UV - vec2(0.5, 0.5));

    // Apply smoothstep function to control transition between areas
    float blur = smoothstep(blur_inner - blur_radius, blur_outer, distance);

    // Mix colors of the blur effect and the original color based on the smoothstep value
    pixelColor.rgb = mix(blurColor.rgb, COLOR.rgb, -blur);

    // Set the alpha component of the blur effect to the smoothstep value
    blurColor.a = blur;

    // Mix colors of the blur effect with white for an additional effect
    blurColor.rgb = mix(blurColor.rgb, vec3(1.0), 0.1);
	//BLUR END
	
	
	// Clamp the final color to make sure it stays in the valid range
	COLOR = clamp(original_color * blurColor, 0.0, 1.0);
}

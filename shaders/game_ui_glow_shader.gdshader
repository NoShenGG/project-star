shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.1, .6, 1.0, 1.0); // Yellow glow
uniform float glow_power : hint_range(0.0, 8.0) = 2.0;
uniform float glow_shift : hint_range(0.0, 10.0) = 1.0;
uniform float glow_radius : hint_range(1.0, 10.0) = 1.0;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    // Implement your glow logic here, e.g., blurring, color blending
    // This is a simplified example; a full glow shader would be more complex
    COLOR = original_color + glow_color * original_color.a * glow_power;
}
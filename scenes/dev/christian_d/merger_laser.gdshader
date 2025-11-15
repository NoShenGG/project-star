/*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/energy-beams

This shader is under CC0 license. Feel free to use, improve and
change this shader according to your needs and consider sharing
the modified result to godotshaders.com.
*/

shader_type spatial;
render_mode blend_add; // Remove this if you want to use HDR glow instead (use "Glow" and "Outline Glow" sliders)

uniform int beams = 3; // How many beams the energy field should have

uniform float energy = 5.0; // How much the beams will travel up and down
uniform int roughness : hint_range(1, 10) = 3; // How compact the noise texture will be
uniform int frequency = 10; // Amount of "ripples" in the beams

uniform float speed = 1.0; // Animation speed
uniform float thickness : hint_range(0.0, 3.0) = 0.006; // Thickness of the main beam
uniform float outline_thickness : hint_range(0.0, 3.0) = 0.03; //Thickness of the outline color
uniform float beam_difference : hint_range(0.0, 1.0) = 0.0; // The thickness difference between the main beam and the other, if there are more than one beam. The closer to 1 the smaller the thickness difference.

uniform float glow : hint_range(0.0, 3.0) = 0.0; // Use together with WorldEnvironment's Glow feature
uniform float outline_glow : hint_range(0.0, 3.0) = 0.0;

uniform vec4 color : source_color = vec4(0.91, 1.0, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.5, 1.0, 0.96, 1.0);

uniform float progress : hint_range(0.0, 1.0) = 1.0;

uniform float y_offset : hint_range (-0.5, 0.5) = 0.0; // Position of the beam
uniform float fixed_edge_size : hint_range(0.0, 0.5) = 0.05; // How close to the edge should the beam be still before the animatino starts
uniform vec2 noise_scale = vec2(1.0); // If the object (for example the ColorRect or Sprite node) is compressed use this to compensate for the noise texture being compressed.

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv, float time) {
    int octaves = roughness;
    float amp = 0.01 * energy * progress;
    float freq = float(frequency);
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amp * noise(freq * vec2(uv.x, uv.y + time));
        amp *= 0.5;
        freq *= 2.0;
    }
    return value;
}

vec4 difference(vec4 base, vec4 blend){
	return abs(base - blend);
}

vec4 bolt(vec2 uv, float time, float i)
{
    // *** MODIFICATION: Swap UV.x and UV.y to rotate the beam to vertical. ***
    vec2 rotated_uv = vec2(uv.y, uv.x);
    // ------------------------------------------------------------------------

	// Setup the beam locking to the edges. Now using rotated_uv.x (original uv.y)
	float falloff = smoothstep(0.0, fixed_edge_size, rotated_uv.x) * smoothstep(0.0, fixed_edge_size, 1.0 - rotated_uv.x);

	// Use Fractal Brownian Motion to create a "cloud texture" and use Difference blend mode to make the beam
    // We use rotated_uv for the main beam logic
	vec4 clouds = vec4(fbm((rotated_uv + vec2(i) ) * noise_scale, time * speed)) * falloff;
	vec4 diff_clouds = difference(clouds, vec4(rotated_uv.y - 0.5 + y_offset + (rotated_uv.y * falloff * 0.02 * energy * progress)));

	// Create a new noise to mask the beams on low "progress" values. To make a "turn-off" effect more visually interesting.
    // Use the original UV for the masking noise, or rotated_uv for a rotated effect
	vec4 clouds2 = vec4(fbm((rotated_uv * 2.0) * noise_scale, time * 1.)) * 5.0; // Using rotated_uv here too for consistency
	diff_clouds += smoothstep(0.0, 0.8, clouds2) * 0.1 * (1.-progress);

	// Set thickness of the beams. First beam is the Thickness size and all following beams are sized with beam_difference
	float thickness2 =  1. - ( thickness / (min(i + beam_difference, 1.0) + (1.0-beam_difference))) * progress ;
	vec4 beam = clamp(smoothstep(thickness2, thickness2 + 0.005 * progress, 1.0 - diff_clouds), vec4(0.0), vec4(1.0));

	//Set the beam outlines
	vec4 beam_outline;
	float outline = thickness2 - (outline_thickness * progress);
	beam_outline = clamp(smoothstep(outline, outline + 0.04, 1.0 - diff_clouds), 0.0, 1.0);
	beam_outline = clamp(beam_outline - beam, 0.0, 1.0);

	// Merge the beam and the outline and return to the fragment function
	return (beam * (color + vec4(glow, glow, glow, 0.))) + (beam_outline * (outline_color + vec4(outline_glow, outline_glow, outline_glow, 0.)));
}

void fragment()
{
	vec4 beam = vec4(0.0);

	for (int i = 0; i < beams; i++){
		beam = max(beam, bolt(UV, TIME, float(i)));
	}

	ALBEDO = beam.rgb;
}
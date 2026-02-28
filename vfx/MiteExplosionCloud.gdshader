shader_type spatial;

uniform sampler2D cloud_noise : source_color, repeat_enable;
uniform sampler2D fireball_noise : source_color, repeat_enable;
uniform sampler2D explosion_noise : source_color, repeat_enable;
uniform sampler2D color_ramp : source_color;
uniform vec4 explosion_color : source_color;
uniform float explosion_amount : hint_range(0.0, 1.0, 0.01);

void vertex() {
	float x = texture(cloud_noise, UV + vec2(0,TIME)).r*0.25 + 1.0;
	VERTEX += vec3(x,x,x) * NORMAL;
}

void fragment() {
	vec4 w = texture(color_ramp, vec2(texture(fireball_noise,UV).r,0));
	ALBEDO = vec3(w.r,w.g,w.b);
	vec4 y = explosion_color;
	
	vec4 z = vec4(y.r*20.0,y.g*20.0,y.b*20.0,y.a) * smoothstep(COLOR.r, 1, texture(explosion_noise,UV));
	EMISSION = vec3(z.r,z.g,z.b);
	ALPHA = COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

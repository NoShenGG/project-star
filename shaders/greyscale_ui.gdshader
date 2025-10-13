shader_type canvas_item;


void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	float gray = tex_color.r * .299 + tex_color.g * .587 + tex_color.b * .114;
	
	COLOR = vec4(vec3(gray), tex_color.a);
}
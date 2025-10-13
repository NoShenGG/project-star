shader_type spatial;

uniform sampler2D albedo;
uniform sampler2D height_map;
uniform float texture_scale = 1.0;
uniform vec3 tint = vec3(1.0, 1.0, 1.0);
uniform uint shell_count = 10;
uniform uint shell_idx = 0;
uniform float shell_displacement = 0.05;
uniform float min_ambient_occlusion = 0.5;

void vertex()
{
	float a = float(shell_idx) / float(shell_count - uint(1));
	VERTEX += NORMAL * shell_displacement * a;
	UV *= texture_scale;
}

void fragment()
{	
	float shell_height = float(shell_idx) / float(shell_count);
	float wool_height = texture(height_map, UV).r;
	if (wool_height < shell_height)
	{
		discard;
	}
	
	float ambient_occlusion = shell_height * (float(shell_count) - 1.0) / float(shell_count) * (1.0 - min_ambient_occlusion) + min_ambient_occlusion;
	ALBEDO = texture(albedo, UV).rgb * tint * ambient_occlusion;
	
	float alpha = 1.0;
	if (shell_height != 0.0)
	{
		alpha = wool_height * pow(1.0 - shell_height, 2) + 0.1;
		alpha = min(1.0, alpha);
	}
	ALPHA = alpha;
}
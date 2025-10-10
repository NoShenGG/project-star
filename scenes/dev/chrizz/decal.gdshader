shader_type spatial;
render_mode world_vertex_coords, unshaded;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform float cube_half_size = 1.0;
uniform float radius : hint_range(0.0, 10.0) = 1.0;
uniform float outerRadius : hint_range(0.0, 10.0) = 1.2;

//Color lerping
uniform vec4 innerColor : source_color;
uniform vec4 outerColor : source_color;
uniform vec4 starColorLow : source_color;
uniform vec4 starColorHigh : source_color;

//Rendering
uniform float stepSize = 0.1;
uniform float pixelation = 128.;
uniform float posterizeLevels = 3;
uniform sampler2D glitch_tex;

//Stars and grid
uniform float starScrollSpeed = 0.5;
uniform sampler2D star_tex;
uniform sampler2D grid_tex;

varying mat4 INV_MODEL_MATRIX;

void vertex(){
	INV_MODEL_MATRIX = inverse(MODEL_MATRIX);
}

//Decal UVs
vec3 world_pos_from_depth(float depth, vec2 screen_uv, mat4 inverse_proj, mat4 inverse_view) {
	float z = depth;
	
	vec4 clipSpacePosition = vec4(screen_uv * 2.0 - 1.0, z, 1.0);
	vec4 viewSpacePosition = inverse_proj * clipSpacePosition;
	
	viewSpacePosition /= viewSpacePosition.w;
	
	vec4 worldSpacePosition = inverse_view * viewSpacePosition;
	
	return worldSpacePosition.xyz;
}

vec3 posterize(vec3 color, float levels) {
    return floor(color * levels) / levels;
}

//Portal UVs
uniform float PORTAL_RADIUS = 0.5;
uniform vec3 PORTAL_NORMAL = vec3(0, 0, 1);
uniform vec3 PORTAL_CENTER = vec3(0, 0, 0);
uniform vec3 PORTAL_SEAM = vec3(0, 1, 0);
uniform sampler2D INSIDE_TEXTURE: source_color, repeat_enable;

vec3 perpendicular_part(vec3 direction, vec3 axis) {
    return direction - dot(direction, axis) * axis;
}

vec3 parallel_part(vec3 direction, vec3 axis) {
    return dot(direction, axis) * axis;
}

float angle_between(vec3 vec, vec3 reference) {
    return atan(length(cross(vec, reference)), dot(vec, reference));
}

float signed_angle_between(vec3 vec, vec3 reference, vec3 normal) {	
    vec3 cross_to = cross(vec, reference);
	float unsigned_angle = atan(length(cross_to), dot(vec, reference));
	return (dot(cross_to, normal) < 0.) ? unsigned_angle : -unsigned_angle;
}

// Uses a triangle projected onto the plane with points
// - circle center
// - vertex
// - intersection point on the edge of the circle
// and uses the law of sines to compute the relevant distance
vec2 portal_uv(vec3 ray_dir, vec3 ray_start, vec3 portal_center, vec3 portal_normal, vec3 portal_seam, float portal_radius) {
    vec3 lateral_ray = perpendicular_part(ray_dir, portal_normal);
    vec3 lateral_direction = normalize(lateral_ray);
    vec3 initial_offset = ray_start - portal_center;
    vec3 initial_direction = normalize(initial_offset);
    float radius_angle = angle_between(lateral_direction, -initial_direction);
    float sin_ratio = portal_radius / sin(radius_angle);
    float center_angle = asin(length(initial_offset) / sin_ratio);
    float lateral_angle = PI - radius_angle - center_angle;
    float lateral_distance = sin_ratio * sin(lateral_angle);
    
    vec3 flat_intersection_offset = initial_offset + lateral_distance * lateral_direction;
    float portal_angle = signed_angle_between(normalize(flat_intersection_offset), -portal_seam, portal_normal);
    float depth = abs(dot(ray_dir, portal_normal)) / length(lateral_ray) * lateral_distance;
    return vec2((portal_angle + PI) / TAU, depth);
}

void fragment() {
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    vec3 world_pos = world_pos_from_depth(depth, SCREEN_UV, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
    
    world_pos *= pixelation;
    world_pos = floor(world_pos.xyz);
    world_pos /= pixelation;
    
    vec4 test_pos = INV_MODEL_MATRIX * vec4(world_pos, 1.0);
    

    // Cube clipping
    if (abs(test_pos.x) > cube_half_size || abs(test_pos.y) > cube_half_size || abs(test_pos.z) > cube_half_size) {
        discard;
    }

    // Distance field from object origin
    float dist = length(test_pos.xyz);
    float alpha = 1.0 - smoothstep(radius - stepSize, radius + stepSize, dist);
	
	vec3 glitchOffset1 = texture(glitch_tex, test_pos.xz * 0.5 + 0.5 + vec2(TIME * 0.03, 0.)).rgb;
	glitchOffset1 = pow(glitchOffset1, vec3(0.4));
	vec3 glitchOffset2 = texture(glitch_tex, test_pos.xz * 0.5 + 0.5 + vec2(TIME * -0.03, 0.)).rgb;
	glitchOffset2 = pow(glitchOffset2, vec3(0.4));
	vec3 glitchOffset3 = texture(glitch_tex, test_pos.xz * 0.5 + 0.5 + vec2(0., TIME * 0.03)).rgb;
	glitchOffset3 = pow(glitchOffset3, vec3(0.4));
    vec3 glitchOffset4 = texture(glitch_tex, test_pos.xz * 0.5 + 0.5 + vec2(0., TIME * -0.03)).rgb;
    glitchOffset4 = pow(glitchOffset4, vec3(0.4));
	vec3 glitchOffset = glitchOffset1 * glitchOffset2 * glitchOffset3 * glitchOffset4;
	
	//Handle stars
	float offset1 = starScrollSpeed * TIME;
	float offset2 = 1.0 - starScrollSpeed * TIME * 0.5;
	float offset3 = starScrollSpeed * TIME * 0.75;
	
	vec3 stars = texture(star_tex, (test_pos.xz) + 0.5).rgb;
	
	float stars1 = mod(stars.x + offset1, 1.);
	float stars2 = mod(stars.y + offset2, 1.);
	float stars3 = mod(stars.z + offset3, 1.);

	float starsT = clamp(stars1 * stars.x + stars2 * stars.y + stars3 * stars.z, 0., 1.);
	vec3 starsOutput = (mix(starColorHigh, starColorLow, starsT)).xyz; 

    //ALBEDO = texture(texture_albedo, (test_pos.xz) + 0.5).rgb * alpha;
	ALBEDO = posterize(mix(innerColor.xyz, outerColor.xyz, alpha + glitchOffset), posterizeLevels) + starsOutput * alpha;
	ALPHA = posterize(vec3(1.0 - smoothstep(radius - stepSize, radius + stepSize, dist - (glitchOffset.x * alpha * 2.))), posterizeLevels).x;
}
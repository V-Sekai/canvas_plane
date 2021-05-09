shader_type spatial;

render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;

uniform sampler2D texture_albedo : hint_albedo;
uniform float bias = 0.0;
uniform int billboard_mode = 0;

void vertex() {
	UV=vec2(UV.x, 1.0 - UV.y);
	if (billboard_mode >= 1) {
		
		mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
		
	    vec3 target_position = CAMERA_MATRIX[3].xyz; // camera position?
	    vec3 vertex = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	    vec3 origin = (WORLD_MATRIX * vec4(0,0,0,1)).xyz;
	    vec3 forward = normalize(target_position - origin);
	    vec3 right = normalize(cross(vec3(0,1,0),forward));
		vec3 up;
		if (billboard_mode >= 2) {
	    	up = vec3(0.0, 1.0, 0.0); //normalize(cross(forward,right));
			forward = cross(right, up);
		} else {
			up = normalize(cross(forward,right));
		}
	    mat3 mat = (mat3(right * length(WORLD_MATRIX[0]), up * length(WORLD_MATRIX[1]), forward * length(WORLD_MATRIX[2])));
		MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(vec4(mat[0], 0.0), vec4(mat[1], 0.0), vec4(mat[2], 0.0), WORLD_MATRIX[3]);
	}
}

vec3 srgb_conversion(vec3 pixel) {
	return mix(pow((pixel + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),pixel.rgb * (1.0 / 12.92),lessThan(pixel,vec3(0.04045)));
}

vec4 ordered_grid_super_sampling(sampler2D p_texture, vec2 p_uv, float p_bias) {
	vec2 dx = dFdx(p_uv);
	vec2 dy = dFdy(p_uv);
	
	const vec2 UV_OFFSETS = vec2(0.125, 0.375);
	
	vec2 offset_uv = vec2(0.0, 0.0);
	
	vec4 color;
	
	offset_uv.xy = p_uv + UV_OFFSETS.x * dx + UV_OFFSETS.y * dy;
	color += texture(p_texture, offset_uv, p_bias);
	offset_uv.xy = p_uv - UV_OFFSETS.x * dx - UV_OFFSETS.y * dy;
	color += texture(p_texture, offset_uv, p_bias);
	offset_uv.xy = p_uv + UV_OFFSETS.y * dx - UV_OFFSETS.x * dy;
	color += texture(p_texture, offset_uv, p_bias);
	offset_uv.xy = p_uv - UV_OFFSETS.y * dx + UV_OFFSETS.x * dy;
	color += texture(p_texture, offset_uv, p_bias);
	
	color *= 0.25;
	
	return color;
}

void fragment() {
	vec4 color = ordered_grid_super_sampling(texture_albedo, UV, bias);
	
	ALBEDO = srgb_conversion(color.rgb);
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	SPECULAR = 0.5;
	ALPHA = color.a;
}

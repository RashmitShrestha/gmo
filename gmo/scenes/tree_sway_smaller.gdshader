shader_type canvas_item;

uniform float sway_intensity = 3.0;
uniform float sway_speed = 3.0;

void vertex() {
    // Wind sway
    vec2 sway = vec2(0.0);
	
	if (VERTEX.y < 0.0) {
		sway.x = sin(TIME * sway_speed + UV.y * 4.0) * sway_intensity;
	}
    // Apply sway mostly to leaves
    VERTEX.xy += sway;
}

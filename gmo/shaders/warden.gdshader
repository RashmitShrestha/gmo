shader_type canvas_item;

// 0.0 is no red applied, 1.0 is strong red applied
uniform float flash = 0.0;

void fragment() {
	// get corresponding pixel color from original
    vec4 base = texture(TEXTURE, UV);
	
	// get red color
    vec4 red_tint = vec4(1.0, 0.0, 0.0, 1.0);
	
	// mix the original color and teh new red color, adjust intensity
    COLOR = mix(base, red_tint, flash) * base.a;
}
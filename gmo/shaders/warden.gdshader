shader_type canvas_item;

uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    // mix base color with red
    vec4 red_tint = vec4(1.0, 0.0, 0.0, 1.0);

    // flash_strength controls how red the sprite gets
    COLOR = mix(base, red_tint, flash_strength) * base.a;
}
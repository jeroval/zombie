// Original calibration candidate for opaque surfaces, not an approved game material.
// White ink-mask pixels apply ink. Author and inspect real surface marks separately.
shader_type spatial;
render_mode specular_disabled, ambient_light_disabled;

uniform sampler2D color_texture : source_color, hint_default_white;
uniform sampler2D ink_mask : hint_default_black;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 ink_color : source_color = vec4(0.012, 0.01, 0.015, 1.0);
uniform float ink_strength : hint_range(0.0, 1.0) = 1.0;
uniform float shadow_value : hint_range(0.0, 1.0) = 0.38;
uniform float middle_value : hint_range(0.0, 1.0) = 0.70;
uniform float dark_threshold : hint_range(0.0, 1.0) = 0.35;
uniform float light_threshold : hint_range(0.0, 1.0) = 0.68;
uniform float transition_width : hint_range(0.001, 0.2) = 0.025;

void fragment() {
    vec3 color = texture(color_texture, UV).rgb * base_color.rgb;
    float ink = clamp(texture(ink_mask, UV).r * ink_strength, 0.0, 1.0);
    ALBEDO = mix(color, ink_color.rgb, ink);
    ROUGHNESS = 1.0;
}

void light() {
    float n_dot_l = max(dot(NORMAL, LIGHT), 0.0);
    float width = max(transition_width, 0.001);
    float upper = max(light_threshold, dark_threshold + width);
    float middle = clamp(middle_value, shadow_value, 1.0);
    float band = mix(shadow_value, middle,
        smoothstep(dark_threshold - width, dark_threshold + width, n_dot_l));
    band = mix(band, 1.0, smoothstep(upper - width, upper + width, n_dot_l));
    // Godot applies ALBEDO; do not multiply it again here.
    // Cast-shadow attenuation is separate from the diffuse bands.
    DIFFUSE_LIGHT += band * ATTENUATION * LIGHT_COLOR / PI;
}

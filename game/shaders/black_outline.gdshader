// Original inverted-hull candidate. Width is in object units, not screen pixels.
// Calibrate applied scale, smooth/shared normals, joins, deformation and shadow cost.
shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 ink_color : source_color = vec4(0.012, 0.01, 0.015, 1.0);
uniform float outline_width : hint_range(0.0, 0.05) = 0.008;

void vertex() {
    VERTEX += NORMAL * outline_width;
}

void fragment() {
    ALBEDO = ink_color.rgb;
}

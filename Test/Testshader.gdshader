shader_type canvas_item;

// Déclare la variable 'angle' comme un float uniform
uniform float angle = 0.0;

void fragment() {
    // Exemple : rotation des UVs de la texture
    vec2 rotated_uv = vec2(
        cos(angle) * (UV.x - 0.5) + sin(angle) * (UV.y - 0.5) + 0.5,
        -sin(angle) * (UV.x - 0.5) + cos(angle) * (UV.y - 0.5) + 0.5
    );
    COLOR = texture(TEXTURE, rotated_uv);
}
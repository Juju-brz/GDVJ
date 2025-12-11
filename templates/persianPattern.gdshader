shader_type canvas_item;

// Uniform pour la résolution de l'écran (optionnel, si tu veux passer la résolution manuellement)
uniform vec2 resolution = vec2(1024.0, 768.0);

void fragment() {
    // Coordonnées normalisées (de 0 à 1)
    vec2 uv = UV;

    // Si tu veux utiliser la résolution réelle de l'écran :
    // vec2 uv = UV * resolution;

    // Couleur basée sur la position horizontale (comme dans ton exemple)
    vec3 col = vec3(uv.x);

    // Sortie finale
    COLOR = vec4(col, 1.0);
}

package raytracer

import m "raytracer:math"

Material :: struct {
    color: Color,

    ambient,
    diffuse,
    specular,
    shininess ,
    reflective: m.real,


    pattern: ^Pattern,
}

material_cadss :: proc(color      : Color    = WHITE,
                       ambient    : m.real   = 0.1,
                       diffuse    : m.real   = 0.9,
                       specular   : m.real   = 0.9,
                       shininess  : m.real   = 200,
                       reflective : m.real   = 0,
                       pattern    : ^Pattern = nil) -> Material {

    return Material { color, ambient, diffuse, specular, shininess, reflective, pattern };
}

material_m_c :: proc(original: Material, color := WHITE) -> Material {
    result := original;
    result.color = color;
    return result;
}

material :: proc {
    material_cadss,
    material_m_c,
}

package graphics

import m "raytracer:math"

Material :: struct {
    color: Color,

    ambient,
    diffuse,
    specular,
    shininess: m.real,
}

@(private="file")
default_color     :        : WHITE;
@(private="file")
default_ambient   : m.real : 0.1;
@(private="file")
default_diffuse   : m.real : 0.9;
@(private="file")
default_specular  : m.real : 0.9;
@(private="file")
default_shininess : m.real : 200;

default_material :: Material {
    default_color,
    default_ambient,
    default_diffuse,
    default_specular,
    default_shininess,
};

material_cadss :: proc(color     := default_color,
                       ambient   := default_ambient,
                       diffuse   := default_diffuse,
                       specular  := default_specular,
                       shininess := default_shininess) -> Material {

    return Material { color, ambient, diffuse, specular, shininess };
}

material_m_c :: proc(original: Material, color := default_color) -> Material {
    result := original;
    result.color = color;
    return result;
}

material :: proc {
    material_cadss,
    material_m_c,
}

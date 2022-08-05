package graphics

import m "raytracer:math"

Material :: struct {
    color: Color,

    ambient,
    diffuse,
    specular,
    shininess: m.real,
}

material :: proc(color     := WHITE,
                 ambient   : m.real = 0.1,
                 diffuse   : m.real = 0.9,
                 specular  : m.real = 0.9,
                 shininess : m.real = 200) -> Material {

    return Material { color, ambient, diffuse, specular, shininess };
}


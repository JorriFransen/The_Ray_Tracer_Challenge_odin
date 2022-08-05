package graphics

import m "raytracer:math"

Material :: struct {
    color: Color,

    ambient,
    diffuse,
    specular,
    shininess: m.Tuple_Element_Type,
}

float :: m.Tuple_Element_Type;

material :: proc(color     := WHITE,
                 ambient   : float = 0.1,
                 diffuse   : float = 0.9,
                 specular  : float = 0.9,
                 shininess : float = 200) -> Material {

    return Material { color, ambient, diffuse, specular, shininess };
}


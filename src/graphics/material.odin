package graphics

import m "raytracer:math"

Material :: struct {
    color: Color,

    ambient,
    diffuse,
    specular,
    shininess: m.Tuple_Element_Type,
}

material :: proc() -> Material {
    return Material {
        color = color(1, 1, 1),
        ambient = 0.1,
        diffuse = 0.9,
        specular = 0.9,
        shininess = 200,
    };
}


package graphics

import "core:math"

import m "raytracer:math"
import g "raytracer:graphics"

Point_Light :: struct {
    position: m.Point,
    intensity : Color,
}

point_light :: proc(p: m.Point, i: Color) -> Point_Light {
    return Point_Light { p, i };
}

lighting :: proc(mat: Material, l: Point_Light, p: m.Point, eye_v: m.Vector, normal_v: m.Vector) -> g.Color {

    effective_color := mat.color * l.intensity;

    light_v := m.normalize(m.sub(l.position, p));

    ambient := effective_color * mat.ambient;

    light_dot_normal := m.dot(light_v, normal_v)

    diffuse, specular : g.Color;

    if light_dot_normal < 0 {
        diffuse = g.BLACK;
        specular = g.BLACK;
    } else {
        diffuse = effective_color * mat.diffuse * light_dot_normal;

        reflect_v := m.reflect(-light_v, normal_v);
        reflect_dot_eye := m.dot(reflect_v, eye_v);

        if reflect_dot_eye <= 0 {
            specular = g.BLACK;
        } else {
            factor := math.pow(reflect_dot_eye, mat.shininess);
            specular = l.intensity * mat.specular * factor;
        }
    }

    return ambient + diffuse + specular;
}

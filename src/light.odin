package raytracer

import "core:math"

import m "raytracer:math"

Point_Light :: struct {
    position: m.Point,
    intensity : Color,
}

point_light :: proc(p: m.Point, i: Color) -> Point_Light {
    return Point_Light { p, i };
}

lighting :: proc(obj: ^Shape, l: Point_Light, p: m.Point, eye_v: m.Vector, normal_v: m.Vector, in_shadow := false) -> Color {

    mat := obj.material;

    color := mat.color;
    if mat.pattern != nil {
        color = pattern_at_shape(mat.pattern, obj, p);
    }

    effective_color := color * l.intensity;

    light_v := m.normalize(m.sub(l.position, p));

    ambient := effective_color * mat.ambient;

    light_dot_normal := m.dot(light_v, normal_v)

    diffuse, specular : Color;

    if light_dot_normal < 0 {
        diffuse = BLACK;
        specular = BLACK;
    } else {
        diffuse = effective_color * mat.diffuse * light_dot_normal;

        reflect_v := m.reflect(-light_v, normal_v);
        reflect_dot_eye := m.dot(reflect_v, eye_v);

        if reflect_dot_eye <= 0 {
            specular = BLACK;
        } else {
            factor := math.pow(reflect_dot_eye, mat.shininess);
            specular = l.intensity * mat.specular * factor;
        }
    }

    if in_shadow do return ambient;
    return ambient + diffuse + specular;
}

reflected_color :: proc(w: ^World, hit: ^Hit_Info) -> Color {
    
    if hit.object.material.reflective == 0 do return BLACK;

    reflect_ray := m.ray(hit.over_point, hit.reflect_v);
    color := color_at(w, reflect_ray);

    return color * hit.object.material.reflective;
}

package raytracer

import "core:math"

import m "raytracer:math"

import "tracy:."

Point_Light :: struct {
    position: m.Point,
    intensity : Color,
}

point_light :: proc(p: m.Point, i: Color) -> Point_Light {
    return Point_Light { p, i };
}

lighting :: proc(obj: ^Shape, l: Point_Light, p: m.Point, eye_v: m.Vector, normal_v: m.Vector, in_shadow := false) -> Color {

    tracy.Zone();

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

reflected_color :: proc(w: ^World, hit: ^Hit_Info, intersections: ^Intersection_Buffer, hi_mem: []^Shape, remaining := 5) -> Color {

    tracy.Zone();

    if remaining <= 0 do return BLACK;
    if hit.object.material.reflective == 0 do return BLACK;

    reflect_ray := m.ray(hit.over_point, hit.reflect_v);
    remaining := remaining - 1;
    color := color_at(w, reflect_ray, intersections, hi_mem, remaining, true);

    return color * hit.object.material.reflective;
}

refracted_color :: proc(w: ^World, hit: ^Hit_Info, intersections: ^Intersection_Buffer, hi_mem: []^Shape, remaining: int) -> Color {

    tracy.Zone();

    if remaining <= 0 do return BLACK;
    if hit.object.material.transparency == 0 do return BLACK;

    // Check for total internal reflection
    n_ratio := hit.n1 / hit.n2;
    cos_i := m.dot(hit.eye_v, hit.normal_v);
    sin2_t := n_ratio * n_ratio * (1 - cos_i * cos_i);
    if sin2_t > 1 do return BLACK;

    cos_t := math.sqrt(1 - sin2_t);

    direction := hit.normal_v * (n_ratio * cos_i - cos_t) - hit.eye_v * n_ratio;

    refract_ray := m.ray(hit.under_point, direction);

    return color_at(w, refract_ray, intersections, hi_mem, remaining - 1) * hit.object.material.transparency;
}

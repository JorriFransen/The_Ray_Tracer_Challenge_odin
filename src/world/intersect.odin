package world

import "core:math"
import "core:slice"

import m "raytracer:math"

Intersection :: struct {
    t: m.real,
    object: Shape,
}

Hit_Info :: struct {
    t: m.real,
    object: Shape,
    point: m.Point,
    eye_v: m.Vector,
    normal_v: m.Vector,

    inside: bool,
}

intersection :: proc(t: m.real, s: Shape) -> Intersection {
    return Intersection { t, s };
}

intersections_from_slice :: proc(intersections: .. Intersection, allocator := context.allocator) -> [dynamic]Intersection {
    result := slice.clone_to_dynamic(intersections, allocator);
    slice.sort_by(result[:], intersection_less);
    return result;
}

intersections_from_dyn_arr_and_slice :: proc(dxs: ^[dynamic]Intersection, ixs: .. Intersection) {
    append(dxs, .. ixs);
    slice.sort_by(dxs[:], intersection_less);
}

intersections :: proc {
    intersections_from_slice,
    intersections_from_dyn_arr_and_slice,
}

hit_info :: proc(i: Intersection, r: m.Ray) -> Hit_Info {

    obj := i.object;
    point := m.ray_position(r, i.t);

    eye_v := m.negate(r.direction);
    normal_v := shape_normal_at(&obj, point);

    inside := false;
    if m.dot(normal_v, eye_v) < 0 {
        inside = true;
        normal_v = m.negate(normal_v);
    }

    return Hit_Info {
        t = i.t,
        object = i.object,
        point = point,
        eye_v = eye_v,
        normal_v = normal_v,
        inside = inside,
    };
}

@private
intersection_less :: proc(a, b: Intersection) -> bool {
    return a.t < b.t;
}

hit :: proc(xs: []Intersection) -> Maybe(Intersection) {

    for i in xs {
        if i.t >= 0 do return i;
    }

    return nil;
}

intersects_shape :: proc(s: Shape, r: m.Ray) -> Maybe([2]Intersection) {

    switch k in s {
        case Sphere: return intersects(k, r);
    }

    assert(false);
    return nil;
}

intersects_sphere :: proc(s: Sphere, r: m.Ray) -> Maybe([2]Intersection) {

    r := m.ray_transform(r, m.matrix_inverse(s.transform));

    sphere_to_ray := m.sub(r.origin, m.point(0, 0, 0));

    a := m.dot(r.direction, r.direction);
    b := 2 * m.dot(r.direction, sphere_to_ray);
    c := m.dot(sphere_to_ray, sphere_to_ray) - 1;

    discriminant := (b * b) - 4 * a * c;

    if discriminant < 0 {
        return nil;
    }

    discriminant_sqrt := math.sqrt(discriminant);
    a2 := 2 * a;

    t1 := m.real((-b - discriminant_sqrt) / a2);
    t2 := m.real((-b + discriminant_sqrt) / a2);

    assert(t1 <= t2);

    return [?]Intersection { intersection(t1, s), intersection(t2, s) };
}

intersects :: proc {
    intersects_shape,
    intersects_sphere,
}

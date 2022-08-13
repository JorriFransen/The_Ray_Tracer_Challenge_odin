package raytracer

import "core:slice"

import m "raytracer:math"

Intersection :: struct {
    t: m.real,
    object: ^Shape,
}

Hit_Info :: struct {
    t: m.real,
    object: ^Shape,
    point: m.Point,
    over_point: m.Point,
    eye_v: m.Vector,
    normal_v: m.Vector,
    reflect_v: m.Vector,

    inside: bool,
}

intersection :: proc(t: m.real, s: ^Shape) -> Intersection {
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
    normal_v := shape_normal_at(obj, point);

    reflect_v := m.reflect(r.direction, normal_v);

    inside := false;
    if m.dot(normal_v, eye_v) < 0 {
        inside = true;
        normal_v = m.negate(normal_v);
    }

    offset := mul(normal_v, m.FLOAT_EPSILON);
    over_point := m.add(point, offset);
    over_point.w = 1.0;

    assert(m.is_point(over_point));

    return Hit_Info {
        t = i.t,
        object = i.object,
        point = point,
        over_point = over_point,
        eye_v = eye_v,
        normal_v = normal_v,
        reflect_v = reflect_v,
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

intersects :: proc(shape: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

    assert(shape.vtable.intersects != nil);

    r := m.ray_transform(r, shape.inverse_transform);

    return shape->intersects(r);
}

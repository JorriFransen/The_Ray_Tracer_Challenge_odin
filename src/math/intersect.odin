package rtmath

import "core:math"
import "core:slice"

Intersection :: struct {
    t: Tuple_Element_Type,
    object: Sphere,
}

intersection :: proc(t: Tuple_Element_Type, s: Sphere) -> Intersection {
    return Intersection { t, s };
}

intersections_from_slice :: proc(intersections: .. Intersection, allocator := context.allocator) -> [dynamic]Intersection {
    return slice.clone_to_dynamic(intersections, allocator);
}

intersections_from_dyn_arr_and_slice :: proc(dxs: [dynamic]Intersection, ixs: .. Intersection) -> [dynamic]Intersection {
    dxs := dxs;
    append(&dxs, .. ixs);
    return dxs;
}

intersections :: proc {
    intersections_from_slice,
    intersections_from_dyn_arr_and_slice,
}

hit :: proc(xs: []Intersection) -> Maybe(Intersection) {

    if len(xs) <= 0 do return nil;

    p_res : ^Intersection = nil;

    for it,i in xs {

        if it.t >= 0 {

            if p_res == nil || p_res.t > it.t {
                p_res = &xs[i];
            }
        }
    }

    if p_res == nil {
        return nil;
    } else {
        return p_res^;
    }
}

intersects_sr :: proc(s: Sphere, r: Ray, allocator := context.allocator) -> Maybe([2]Intersection) {

    r := ray_transform(r, matrix_inverse(s.transform));

    sphere_to_ray := sub(r.origin, point(0, 0, 0));

    a := dot(r.direction, r.direction);
    b := 2 * dot(r.direction, sphere_to_ray);
    c := dot(sphere_to_ray, sphere_to_ray) - 1;

    discriminant := (b * b) - 4 * a * c;

    if discriminant < 0 {
        return nil;
    }

    discriminant_sqrt := math.sqrt(discriminant);
    a2 := 2 * a;

    t1 := Tuple_Element_Type((-b - discriminant_sqrt) / a2);
    t2 := Tuple_Element_Type((-b + discriminant_sqrt) / a2);

    assert(t1 <= t2);

    return [?]Intersection { intersection(t1, s), intersection(t2, s) };
}

intersects :: proc {
    intersects_sr,
}
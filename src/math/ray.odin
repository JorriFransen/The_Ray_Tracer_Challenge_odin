package rtmath

import "core:math"

Ray :: struct {
    origin: Point,
    direction: Vector,
}

Intersection :: struct {
    t: Tuple_Element_Type,
    object: Sphere,
}

ray :: proc(o: Point, v: Vector) -> Ray {
    return Ray { o, v };
}

intersection :: proc(t: Tuple_Element_Type, s: Sphere) -> Intersection {
    return Intersection { t, s };
}

intersections :: proc(intersections: .. Intersection) -> []Intersection {
    return intersections;
}

hit :: proc(xs: []Intersection) -> Intersection {

    assert(len(xs) > 0);

    p_res : ^Intersection = nil;

    for it,i in xs {

        if it.t >= 0 {

            if p_res == nil || p_res.t > it.t {
                p_res = &xs[i];
            }
        }
    }

    if p_res == nil {
        return {};
    } else {
        return p_res^;
    }
}

position :: proc(r: Ray, t: Tuple_Element_Type) -> Point {
    distance := r.direction * t;
    return add(r.origin, distance);
}

intersect :: proc(s: Sphere, r: Ray) -> []Intersection {

    // Sphere is always located at (0,0,0)
    sphere_to_ray := sub(r.origin, point(0, 0, 0));

    a := dot(r.direction, r.direction);
    b := 2 * dot(r.direction, sphere_to_ray);
    c := dot(sphere_to_ray, sphere_to_ray) - 1;

    discriminant := (b * b) - 4 * a * c;


    if discriminant < 0 {
        return {};
    }

    discriminant_sqrt := math.sqrt(discriminant);
    a2 := 2 * a;

    t1 := Tuple_Element_Type((-b - discriminant_sqrt) / a2);
    t2 := Tuple_Element_Type((-b + discriminant_sqrt) / a2);

    return { intersection(t1, s), intersection(t2, s) };
}

package rtmath

import "core:math"

Ray :: struct {
    origin: Point,
    direction: Vector,
}

Intersection :: distinct Tuple_Element_Type;

ray :: proc(o: Point, v: Vector) -> Ray {
    return Ray { o, v };
}

position :: proc(r: Ray, t: Tuple_Element_Type) -> Point {
    distance := r.direction * t;
    return add(r.origin, distance);
}

intersects :: proc(s: Sphere, r: Ray) -> []Intersection {

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

    t1 := Intersection((-b - discriminant_sqrt) / a2);
    t2 := Intersection((-b + discriminant_sqrt) / a2);

    return { t1, t2 };
}

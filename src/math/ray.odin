package rtmath

Ray :: struct {
    origin: Point,
    direction: Vector,
}

ray :: proc(o: Point, d: Vector) -> Ray {
    return Ray { o, d };
}

ray_position :: proc(r: Ray, t: Tuple_Element_Type) -> Point {
    distance := r.direction * t;
    return add(r.origin, distance);
}


ray_transform :: proc(r: Ray, m: Matrix4) -> Ray {
    return ray(mul(m, r.origin), mul(m, r.direction));
}

package rtmath

Ray :: struct {
    origin: Point,
    direction: Vector,
    inverse_direction: Vector,
}

ray :: proc(o: Point, d: Vector) -> Ray {
    return Ray { o, d, 1 / d };
}

ray_position :: proc(r: Ray, t: real) -> Point {
    distance := r.direction * t;
    return add(r.origin, distance);
}


ray_transform :: proc(r: Ray, m: Matrix4) -> Ray {
    return ray(matrix4_mul_tuple(m, r.origin), matrix4_mul_tuple(m, r.direction));
}

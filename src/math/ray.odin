package rtmath

Ray :: struct {
    origin: Point,
    direction: Vector,
}

ray :: proc(o: Point, v: Vector) -> Ray {
    return Ray { o, v };
}

position :: proc(r: Ray, t: Tuple_Element_Type) -> Point {
    distance := r.direction * t;
    return add(r.origin, distance);
}

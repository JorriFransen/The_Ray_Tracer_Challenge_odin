package rtmath

@(private="file")

_next_sphere_id := 1;

Sphere :: struct {
    _id: int,
}

sphere :: proc() -> (result: Sphere) {
    result._id = _next_sphere_id;
    _next_sphere_id += 1;
    return;
}

package rtmath

Sphere :: struct {
    transform: Matrix4,
}

sphere_default :: proc() -> (result: Sphere) {
    result.transform = matrix4_identity;
    return;
}

sphere_t :: proc(t: Matrix4) -> (result: Sphere) {
    result.transform = t;
    return;
}

sphere :: proc {
    sphere_default,
    sphere_t,
}

sphere_set_transform :: proc(s: ^Sphere, t: Matrix4) {
    s.transform = t;
}

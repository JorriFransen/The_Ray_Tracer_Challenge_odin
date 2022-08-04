package rtmath

Shape :: struct {
    transform: Matrix4,
}

Sphere :: struct {
    using base: Shape,
}

shape_default :: proc() -> Shape {
    return shape(matrix4_identity);
}

shape_with_transform :: proc(t: Matrix4) -> Shape {
    return Shape { t };
}

shape :: proc {
    shape_default,
    shape_with_transform,
}

sphere_default :: proc() -> Sphere {
    return sphere(matrix4_identity);
}

sphere_with_transform :: proc(t: Matrix4) -> Sphere {
    return Sphere { shape(t) };
}

sphere :: proc {
    sphere_default,
    sphere_with_transform,
}

shape_set_transform :: proc(s: ^Shape, t: Matrix4) {
    s.transform = t;
}

sphere_normal_at :: proc(s: ^Sphere, p: Point) -> Vector {

    s_tf_inv := matrix_inverse(s.transform);

    op : Point = s_tf_inv * p;
    on := sub(op, point(0, 0, 0));

    wn := matrix4_transpose(s_tf_inv) * on;

    // s_tf_inv should be matrix_inverse(matrix_submatrix(s.transform, 3, 3)).
    // But not using the submatrix will only change the w component.
    wn.w = 0;

    assert(is_vector(wn));
    return normalize(wn);
}

shape_normal_at :: proc {
    sphere_normal_at,
}

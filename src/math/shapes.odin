package rtmath

Shape :: struct {
    transform: Matrix4,

    derived: union { ^Sphere },
};


Sphere :: struct {
    using base: Shape,
}

shape_default :: proc(derived: ^$T) -> Shape {
    return Shape { matrix4_identity, derived };
}

shape_t :: proc(derived: ^$T, t: Matrix4) -> Shape {
    return Shape { t, derived };
}

shape :: proc {
    shape_default,
    shape_t,
}

sphere_default :: proc() -> (s: Sphere) {
    s.base = shape(&s);
    return;
}

sphere_t :: proc(t: Matrix4) -> (s: Sphere) {
    s.base = shape(&s, t);
    return;
}

sphere :: proc {
    sphere_default,
    sphere_t,
}

shape_set_transform :: proc(s: ^Shape, t: Matrix4) {
    s.transform = t;
}

shape_normal_at_s :: proc(s: ^Shape, p: Point) -> Vector {

    switch d in s.derived {
        case ^Sphere: return sphere_normal_at(s.derived.(^Sphere), p);
    }

    assert(false);
    return Vector {};
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
    shape_normal_at_s,
    sphere_normal_at,
}

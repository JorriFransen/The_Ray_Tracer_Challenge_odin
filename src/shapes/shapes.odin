package rtshapes

import m "raytracer:math"
import g "raytracer:graphics"

Shape :: struct {
    transform: m.Matrix4,
    material: g.Material,
}

Sphere :: struct {
    using base: Shape,
}

shape_default :: proc() -> Shape {
    return shape(m.matrix4_identity, g.material());
}

shape_t :: proc(t: m.Matrix4) -> Shape {
    return shape(t, g.material());
}

shape_m :: proc(mat: g.Material) -> Shape {
    return shape(m.matrix4_identity, mat);
}

shape_tm :: proc(t: m.Matrix4, m: g.Material) -> Shape {
    return Shape { t, m };
}

shape :: proc {
    shape_default,
    shape_t,
    shape_m,
    shape_tm,
}

sphere_default :: proc() -> Sphere {
    return Sphere { shape() };
}

sphere_t :: proc(t: m.Matrix4) -> Sphere {
    return Sphere { shape(t) };
}

sphere_m :: proc(m: g.Material) -> Sphere {
    return Sphere { shape(m) };
}

sphere_tm :: proc(t: m.Matrix4, m: g.Material) -> Sphere {
    return Sphere { shape(t, m) };
}

sphere :: proc {
    sphere_default,
    sphere_t,
    sphere_m,
    sphere_tm,
}

shape_set_transform :: proc(s: ^Shape, t: m.Matrix4) {
    s.transform = t;
}

shape_set_material :: proc(s: ^Shape, m: g.Material) {
    s.material = m;
}

sphere_normal_at :: proc(s: ^Sphere, p: m.Point) -> m.Vector {

    s_tf_inv := m.matrix_inverse(s.transform);

    op : m.Point = s_tf_inv * p;
    on := m.sub(op, m.point(0, 0, 0));

    wn := m.matrix4_transpose(s_tf_inv) * on;

    // s_tf_inv should be matrix_inverse(matrix_submatrix(s.transform, 3, 3)).
    // But not using the submatrix will only change the w component.
    wn.w = 0;

    assert(m.is_vector(wn));
    return m.normalize(wn);
}

shape_normal_at :: proc {
    sphere_normal_at,
}

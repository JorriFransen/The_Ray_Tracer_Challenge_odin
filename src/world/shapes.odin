package world

import m "raytracer:math"
import g "raytracer:graphics"

Shape_Base :: struct {
    transform: m.Matrix4,
    material: g.Material,
}

Sphere :: struct {
    using base: Shape_Base,
}

Shape :: union { Sphere };

shape_base_default :: proc() -> Shape_Base {
    return shape_base(m.matrix4_identity, g.material());
}

shape_base_t :: proc(t: m.Matrix4) -> Shape_Base {
    return shape_base(t, g.material());
}

shape_base_m :: proc(mat: g.Material) -> Shape_Base {
    return shape_base(m.matrix4_identity, mat);
}

shape_base_tm :: proc(t: m.Matrix4, m: g.Material) -> Shape_Base {
    return Shape_Base { t, m };
}

shape_base :: proc {
    shape_base_default,
    shape_base_t,
    shape_base_m,
    shape_base_tm,
}

sphere_default :: proc() -> Sphere {
    return Sphere { shape_base() };
}

sphere_t :: proc(t: m.Matrix4) -> Sphere {
    return Sphere { shape_base(t) };
}

sphere_m :: proc(m: g.Material) -> Sphere {
    return Sphere { shape_base(m) };
}

sphere_tm :: proc(t: m.Matrix4, m: g.Material) -> Sphere {
    return Sphere { shape_base(t, m) };
}

sphere :: proc {
    sphere_default,
    sphere_t,
    sphere_m,
    sphere_tm,
}

shape_set_transform :: proc(s: ^Shape_Base, t: m.Matrix4) {
    s.transform = t;
}

shape_set_material :: proc(s: ^Shape_Base, m: g.Material) {
    s.material = m;
}

shape_normal_at_ :: proc(s: ^Shape, p: m.Point) -> m.Vector {
    switch in s {
        case Sphere: return sphere_normal_at(&s.?, p);
    }

    assert(false);
    return m.Vector {};
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
    shape_normal_at_,
    sphere_normal_at,
}

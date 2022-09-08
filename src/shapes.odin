package raytracer

import m "raytracer:math"

import "core:mem"

Shape :: struct {
    using vtable: ^Shape_VTable,
    inverse_transform: m.Matrix4,
    material: Material,
}

Shape_Normal_At_Proc :: proc(^Shape, m.Point) -> m.Vector;
Shape_Intersects_Proc :: proc(^Shape, m.Ray) -> ([4]Intersection, int);
Shape_Eq_Proc :: proc(a, b: ^Shape) -> bool;

Shape_VTable :: struct {
    normal_at: Shape_Normal_At_Proc,
    intersects: Shape_Intersects_Proc,
    eq: Shape_Eq_Proc,
}

shape :: proc(vt: ^Shape_VTable, tf: m.Matrix4, mat: Material) -> Shape {

    assert(vt.normal_at != nil);
    assert(vt.intersects != nil);
    assert(vt.eq != nil);

    tf := m.matrix_inverse(tf);

    return Shape { vt, tf, mat };
}

shape_eq :: proc(a, b: Shape) -> bool {


    if a.vtable != b.vtable do return false;
    if a.material != b.material do return false;
    if !eq(a.inverse_transform, b.inverse_transform) do return false;

    assert(a.vtable.eq != nil);

    a := a;
    b := b;

    pa := &a;
    pb := &b;

    return pa->eq(pb);
}

set_transform :: proc(s: ^Shape, new_tf: m.Matrix4) {
    s.inverse_transform = m.matrix_inverse(new_tf);
}

set_material :: proc(s: ^Shape, mat: Material) {
    s.material = mat;
}

shape_normal_at :: proc(s: ^Shape, p: m.Point) -> m.Vector {

    assert(s.vtable.normal_at != nil);

    obj_p := s.inverse_transform * p;

    obj_n := s->normal_at(obj_p);

    world_n := m.matrix4_transpose(s.inverse_transform) * obj_n;
    world_n.w = 0;

    return m.normalize(world_n);
}

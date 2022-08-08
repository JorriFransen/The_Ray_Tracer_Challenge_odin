package world_shapes

import m "raytracer:math"
import g "raytracer:graphics"

import "core:mem"

Shape :: struct {
    inverse_transform: m.Matrix4,
    material: g.Material,

    derived: union { ^Sphere },
}


Spheres :: struct($N: int) {
    spheres: [N]Sphere,
    used: int,
}

Shapes :: struct($N_SPHERES: int) {
    spheres: Spheres(N_SPHERES),
}

shape_eq :: proc(a, b: Shape) -> bool {

    if type_of(a.derived) != type_of(b.derived) do return false;
    if a.material != b.material do return false;
    if !m.eq(a.inverse_transform, b.inverse_transform) do return false;

    switch k in a.derived {
        case ^Sphere: return true;
    }

    assert(false);
    return false;
}

eq :: proc {
    shape_eq,
}

set_transform :: proc(s: ^Shape, new_tf: m.Matrix4) {
    s.inverse_transform = m.matrix_inverse(new_tf);
}

set_material :: proc(s: ^Shape, mat: g.Material) {
    s.material = mat;
}

shape_normal_at :: proc(s: ^Shape, p: m.Point) -> m.Vector {
    switch k in s.derived {
        case ^Sphere: return sphere_normal_at(k, p);
    }

    assert(false);
    return m.Vector{};
}

normal_at :: proc {
    shape_normal_at,
    sphere_normal_at,
}


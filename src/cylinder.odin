package raytracer

import "core:math"

import "tracy:."

import m "raytracer:math"

Cylinder :: struct {
    using shape: Shape,
}

cylinder_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Cylinder {
    return Cylinder { shape(_cylinder_vtable, tf, mat) };
}

cylinder_mat :: proc(mat: Material) -> Cylinder {
    return cylinder_tf_mat(m.matrix4_identity, mat);
}

cylinder_tf :: proc(tf: m.Matrix4) -> Cylinder {
    return cylinder_tf_mat(tf, material());
}

cylinder_default :: proc() -> Cylinder {
    return cylinder_tf_mat(m.matrix4_identity, material());
}

cylinder :: proc {
    cylinder_tf_mat,
    cylinder_tf,
    cylinder_mat,
    cylinder_default,
}

@(private="file")
_cylinder_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {
        return m.vector(p.x, 0, p.z); 
    },

    intersects = cylinder_intersects,

    eq = proc(a, b: ^Shape) -> bool { return true },
};

cylinder_intersects :: proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

    tracy.Zone();

    a := r.direction.x * r.direction.x + r.direction.z * r.direction.z;

    if (eq(a, 0)) do return nil;

    b := (2 * r.origin.x * r.direction.x) + (2 * r.origin.z * r.direction.z);
    c := (r.origin.x * r.origin.x) + (r.origin.z * r.origin.z) - 1;

    disc := (b * b) - (4 * a * c);

    if disc < 0 do return nil;

    disc_sqrt := math.sqrt(disc);
    divisor := 2 * a;

    t0 := (-b - disc_sqrt) / divisor;
    t1 := (-b + disc_sqrt) / divisor;

    return [2]Intersection{ intersection(t0, s), intersection(t1, s) };
}

package raytracer

import m "raytracer:math"

Plane :: struct {
    using shape: Shape,
}

plane_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Plane {
    return Plane { shape(_plane_vtable, tf, mat) };
}

plane_mat :: proc(mat: Material) -> Plane {
    return plane_tf_mat(m.matrix4_identity, mat);
}

plane_tf :: proc(tf: m.Matrix4) -> Plane {
    return plane_tf_mat(tf, material());
}

plane_default :: proc() -> Plane {
    return plane_tf_mat(m.matrix4_identity, material());
}

plane :: proc {
    plane_tf_mat,
    plane_tf,
    plane_mat,
    plane_default,
}

@(private="file")
_plane_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {
        return m.vector(0, 1, 0);
    },

    intersects = proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {
        if abs(r.direction.y) < m.FLOAT_EPSILON do return nil;

        t := -r.origin.y / r.direction.y;

        i := intersection(t, s);
        return [2]Intersection { i, i };
    },

    eq = proc(a, b: ^Shape) -> bool { assert(false); return true; }

};


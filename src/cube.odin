package raytracer

import "core:math"
import "core:time"

import m "raytracer:math"

Cube :: struct {
    using shape: Shape,
}

cube_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Cube {
    return Cube { shape(_cube_vtable, tf, mat) };
}

cube_mat :: proc(mat: Material) -> Cube {
    return cube_tf_mat(m.matrix4_identity, mat);
}

cube_tf :: proc(tf: m.Matrix4) -> Cube {
    return cube_tf_mat(tf, material());
}

cube_default :: proc() -> Cube {
    return cube_tf_mat(m.matrix4_identity, material());
}

cube :: proc {
    cube_tf_mat,
    cube_tf,
    cube_mat,
    cube_default,
}

@(private="file")
_cube_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {

        absx := abs(p.x);
        absy := abs(p.y);
        absz := abs(p.z);

        maxc := max(absx, absy, absz);

        if maxc == absx {
            return m.vector(p.x, 0, 0);
        } else if maxc == absy {
            return m.vector(0, p.y, 0);
        } else if maxc == absz {
            return m.vector(0, 0, p.z);
        }

        assert(false);
        return m.Vector{};
    },

    intersects = proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

        t := start_timing("Cube intersect");
        defer end_timing(&t);

        inv_dir := r.inverse_direction;

        tmin, tmax : m.real;

        if inv_dir.x >= 0 {
            tmin = (-1 - r.origin.x) * inv_dir.x;
            tmax = ( 1 - r.origin.x) * inv_dir.x;
        } else {
            tmin = ( 1 - r.origin.x) * inv_dir.x;
            tmax = (-1 - r.origin.x) * inv_dir.x;
        }

        tymin, tymax : m.real;

        if inv_dir.y >= 0 {
            tymin = (-1 - r.origin.y) * inv_dir.y;
            tymax = ( 1 - r.origin.y) * inv_dir.y;
        } else {
            tymin = ( 1 - r.origin.y) * inv_dir.y;
            tymax = (-1 - r.origin.y) * inv_dir.y;
        }

        if tmin > tymax || tymin > tmax do return nil;

        if tymin > tmin do tmin = tymin;
        if tymax < tmax do tmax = tymax;

        tzmin, tzmax : m.real;

        if inv_dir.z >= 0 {
            tzmin = (-1 - r.origin.z) * inv_dir.z;
            tzmax = ( 1 - r.origin.z) * inv_dir.z;
        } else {
            tzmin = ( 1 - r.origin.z) * inv_dir.z;
            tzmax = (-1 - r.origin.z) * inv_dir.z;
        }

        if tmin > tzmax || tzmin > tmax do return nil;

        if tzmin > tmin do tmin = tzmin;
        if tzmax < tmax do tmax = tzmax;

        return [2]Intersection { intersection(tmin, s), intersection(tmax, s) };
    },

    eq = proc(a, b: ^Shape) -> bool { return true },
};
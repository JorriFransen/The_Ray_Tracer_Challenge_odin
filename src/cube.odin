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
        end_timing(&t);

        xtmin, xtmax := check_axis(r.origin.x, r.direction.x);
        ytmin, ytmax := check_axis(r.origin.y, r.direction.y);
        ztmin, ztmax := check_axis(r.origin.z, r.direction.z);

        tmin := max(xtmin, ytmin, ztmin);
        tmax := min(xtmax, ytmax, ztmax)

        if tmin > tmax do return nil;

        return [2]Intersection { intersection(tmin, s), intersection(tmax, s) };
    },

    eq = proc(a, b: ^Shape) -> bool { return true },
};

import "core:fmt"

@(private="file")
check_axis :: #force_inline proc(origin, direction: m.real) -> (tmin: m.real, tmax: m.real) {

    tmin_num := -1 - origin;
    tmax_num := 1 - origin;

    if abs(direction) >= m.FLOAT_EPSILON {
        tmin = tmin_num / direction;
        tmax = tmax_num / direction;
    } else {
        tmin = tmin_num * m.INFINITY;
        tmax = tmax_num * m.INFINITY;
    }

    if tmin > tmax do tmin, tmax = tmax, tmin;

    return;
}

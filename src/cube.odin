package raytracer

import "core:math"

import "tracy:."

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

    intersects = cube_intersects,

    eq = proc(a, b: ^Shape) -> bool { return true },
};

/*

cube_intersects_a :: proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

    tracy.Zone();

    check_axis :: proc(origin, direction: m.real) -> (tmin, tmax: m.real)
    {
        // t := start_timing("check_axis");
        // defer end_timing(&t);

        tmin_num := (-1 - origin);
        tmax_num := ( 1 - origin);

        if abs(direction) >= m.FLOAT_EPSILON {
            tmin = tmin_num / direction;
            tmax = tmax_num / direction
        } else {
            tmin = tmin_num * m.INFINITY;
            tmax = tmax_num * m.INFINITY;
        }

        if tmin > tmax do tmin, tmax = tmax, tmin;

        return;
    }

    xtmin, xtmax := check_axis(r.origin.x, r.direction.x);
    ytmin, ytmax := check_axis(r.origin.y, r.direction.y);
    ztmin, ztmax := check_axis(r.origin.z, r.direction.z);

    tmin := max(xtmin, ytmin, ztmin);
    tmax := min(xtmax, ytmax, ztmax);

    if tmin > tmax do return nil;

    return [2]Intersection { intersection(tmin, s), intersection(tmax, s) };

}

cube_intersects_b :: proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

    tracy.Zone();

    check_axis :: #force_inline proc(origin, dir, inv_dir: m.real) -> (tmin, tmax: m.real)
    {
        // t := start_timing("check_axis_b");
        // defer end_timing(&t);

        tmin_num := (-1 - origin);
        tmax_num := ( 1 - origin);

        if abs(dir) > m.FLOAT_EPSILON {
            if inv_dir >= 0 {
                tmin = tmin_num * inv_dir;
                tmax = tmax_num * inv_dir;
            } else {
                tmax = tmin_num * inv_dir;
                tmin = tmax_num * inv_dir;
            }
        } else {
            tmin = tmin_num * m.INFINITY;
            tmax = tmax_num * m.INFINITY;
        }

        return;
    }

    tmin, tmax := check_axis(r.origin.x, r.direction.x, r.inverse_direction.x);
    ytmin, ytmax := check_axis(r.origin.y, r.direction.y, r.inverse_direction.y);
    if tmin > ytmax || ytmin > tmax do return nil;

    if ytmin > tmin do tmin = ytmin;
    if ytmax < tmax do tmax = ytmax;

    ztmin, ztmax := check_axis(r.origin.z, r.direction.z, r.inverse_direction.z);

    if tmin > ztmax || ztmin > tmax do return nil;

    if ztmin > tmin do tmin = ztmin;
    if ztmax < tmax do tmax = ztmax;

    return [2]Intersection { intersection(tmin, s), intersection(tmax, s) };

}

*/

cube_intersects :: proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

    tracy.Zone();

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
}

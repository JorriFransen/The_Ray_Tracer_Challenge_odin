package raytracer

import "core:math"

import "tracy:."

import m "raytracer:math"

Cylinder :: struct {
    using shape: Shape,

    minimum, maximum: m.real,
    closed: bool,
}

cylinder_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Cylinder {
    return Cylinder { shape(_cylinder_vtable, tf, mat), -m.INFINITY, m.INFINITY, false };
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

        cyl := transmute(^Cylinder)s;

        if cyl.closed {
            dist := p.x * p.x + p.z * p.z;
            if dist < 1 && p.y >= cyl.maximum - m.FLOAT_EPSILON {
                return m.vector(0, 1, 0);
            } else if dist < 1 && p.y <= cyl.minimum + m.FLOAT_EPSILON {
                return m.vector(0, -1, 0);
            }
        }

        return m.vector(p.x, 0, p.z);
    },

    intersects = cylinder_intersects,

    eq = proc(a, b: ^Shape) -> bool { return true },
};

cylinder_intersects :: proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

    tracy.Zone();

    cyl := transmute(^Cylinder)s;

    a := r.direction.x * r.direction.x + r.direction.z * r.direction.z;

    i0, i1: Intersection;
    count := 0;

    if !eq(a, 0) {

        b := (2 * r.origin.x * r.direction.x) + (2 * r.origin.z * r.direction.z);
        c := (r.origin.x * r.origin.x) + (r.origin.z * r.origin.z) - 1;

        disc := (b * b) - (4 * a * c);

        if disc < 0 do return nil;

        disc_sqrt := math.sqrt(disc);
        divisor := 2 * a;

        t0 := (-b - disc_sqrt) / divisor;
        t1 := (-b + disc_sqrt) / divisor;

        if t0 > t1 do t0, t1 = t1, t0;

        y0 := r.origin.y + t0 * r.direction.y;
        if cyl.minimum < y0 && y0 < cyl.maximum {
            i0 = intersection(t0, cyl);
            i1 = i0;
            count += 1;
        }

        y1 := r.origin.y + t1 * r.direction.y;
        if cyl.minimum < y1 && y1 < cyl.maximum {
            i1 = intersection(t1, cyl);
            count += 1;

            if count == 1 {
                i0 = i1;
            }
        }
    }

    if cyl.closed && count < 2 {
        if cap_xs, cap_ok := intersect_caps(cyl, r).?; cap_ok {
            if count == 0 {
                return cap_xs;
            } else if count == 1 {
                i1 = cap_xs[0];
            }
        }
    }

    if count <= 0 do return nil;

    return [2]Intersection { i0, i1 };
}

intersect_caps :: #force_inline proc(cyl: ^Cylinder, r: m.Ray) -> Maybe([2]Intersection) {

    if abs(r.direction.y) < m.FLOAT_EPSILON do return nil;

    i0, i1: Intersection;
    count := 0;

    t0 := (cyl.minimum - r.origin.y) / r.direction.y;
    x0 := r.origin.x + t0 * r.direction.x;
    z0 := r.origin.z + t0 * r.direction.z;
    if x0 * x0 + z0 * z0 <= 1 {
        i0 = intersection(t0, cyl);
        i1 = i0;
        count += 1;
    }

    t1 := (cyl.maximum - r.origin.y) / r.direction.y;
    x1 := r.origin.x + t1 * r.direction.x;
    z1 := r.origin.z + t1 * r.direction.z;
    if x1 * x1 + z1 * z1 <= 1 {
        i1 = intersection(t1, cyl);

        count += 1;

        if count == 1 {
            i0 = i1;
        }
    }

    if count == 0 do return nil;

    return [2]Intersection { i0, i1 };
}

package raytracer

import m "raytracer:math"
import "tracy:."

import "core:math"

Cone :: struct {
    using cyl: Cylinder,
}

cone_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Cone {
    return Cone { Cylinder { shape(_cone_vtable, tf, mat), -m.INFINITY, m.INFINITY, false }};
}

cone_mat :: proc(mat: Material) -> Cone {
    return cone_tf_mat(m.matrix4_identity, mat);
}

cone_tf :: proc(tf: m.Matrix4) -> Cone {
    return cone_tf_mat(tf, material());
}

cone_default :: proc() -> Cone {
    return cone_tf_mat(m.matrix4_identity, material());
}

cone :: proc {
    cone_tf_mat,
    cone_tf,
    cone_mat,
    cone_default,
}

_cone_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {

        cone := transmute(^Cone)s;

        if cone.closed {
            dist := p.x * p.x + p.z * p.z;
            if dist < 1 && p.y >= cone.maximum - m.FLOAT_EPSILON {
                return m.vector(0, 1, 0);
            } else if dist < 1 && p.y <= cone.minimum + m.FLOAT_EPSILON {
                return m.vector(0, -1, 0);
            }
        }

        y := math.sqrt(p.x * p.x + p.z * p.z);
        y = -y if p.y > 0 else y;
        return m.vector(p.x, y, p.z);
    },

    intersects = cone_intersects,

    eq = proc(a, b: ^Shape) -> bool { return true },
};

cone_intersects :: proc(s: ^Shape, r: m.Ray, xs_buf: ^Intersection_Buffer) -> []Intersection {

    tracy.Zone();

    cone := transmute(^Cone)s;

    old_count := xs_buf.count;

    a := r.direction.x * r.direction.x - r.direction.y * r.direction.y + r.direction.z * r.direction.z;
    b := (2 * r.origin.x * r.direction.x) - (2 * r.origin.y * r.direction.y) + (2 * r.origin.z * r.direction.z);
    c := (r.origin.x * r.origin.x) - (r.origin.y * r.origin.y) +  (r.origin.z * r.origin.z);

    count := 0;

    if !eq(a, 0) {

        disc := (b * b) - (4 * a * c);

        if disc < 0 do return {};

        disc_sqrt := math.sqrt(disc);
        divisor := 2 * a;

        t0 := (-b - disc_sqrt) / divisor;
        t1 := (-b + disc_sqrt) / divisor;

        if t0 > t1 do t0, t1 = t1, t0;

        y0 := r.origin.y + t0 * r.direction.y;
        if cone.minimum < y0 && y0 < cone.maximum {
            append_xs(xs_buf, intersection(t0, cone));
            count += 1;
        }

        y1 := r.origin.y + t1 * r.direction.y;
        if cone.minimum < y1 && y1 < cone.maximum {
            append_xs(xs_buf, intersection(t1, cone));
            count += 1;
        }

    } else if !eq(b, 0) {

        // This means the ray is parallel to one of the con's halves
        t := -c / (2 * b);
        append_xs(xs_buf, intersection(t, cone));
        count += 1;
    }

    if cone.closed && count < 4 {
        cap_xs, cap_count := intersect_caps(cone, r);

        assert(cap_count >= 0 && cap_count <= 2);
        total_count := count + cap_count;
        assert(total_count >= 0 && total_count <= 4);

        for i in 0..<cap_count {
            append_xs(xs_buf, cap_xs[i]);
            count += 1;
        }
    }


    return xs_buf.intersections[old_count:old_count + count];
}

@(private="file")
check_cap :: #force_inline proc(ray: m.Ray, t: m.real, r: m.real) -> bool {

    x := ray.origin.x + t * ray.direction.x;
    z := ray.origin.z + t * ray.direction.z;

    return x * x + z * z <= r;
}

@(private="file")
intersect_caps :: #force_inline proc(cone: ^Cone, r: m.Ray) -> (result: [2]Intersection, count: int) {

    if abs(r.direction.y) < m.FLOAT_EPSILON do return {}, 0;

    count = 0;

    t0 := (cone.minimum - r.origin.y) / r.direction.y;
    if check_cap(r, t0, abs(cone.minimum)) {
        result[count] = intersection(t0, cone);
        count += 1;
    }

    t1 := (cone.maximum - r.origin.y) / r.direction.y;
    if check_cap(r, t1, abs(cone.maximum)) {
        result[count] = intersection(t1, cone);
        count += 1;
    }

    return result, count;
}

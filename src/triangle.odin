package raytracer

import "core:math"
import m "raytracer:math"

import "tracy:."

Triangle :: struct {
    using shape: Shape,

    p1, p2, p3 : m.Point,
    e1, e2     : m.Vector,
    normal     : m.Vector,
}

triangle_tf_mat :: proc(p1, p2, p3: m.Point, tf: m.Matrix4, mat: Material) -> Triangle {
    e1 := m.sub(p2, p1);
    e2 := m.sub(p3, p1);
    normal := m.normalize(m.cross(e2, e1));
    return Triangle { shape(_triangle_vtable, tf, mat), p1, p2, p3, e1, e2, normal };
}

triangle_mat :: proc(p1, p2, p3: m.Point, mat: Material) -> Triangle {
    return triangle_tf_mat(p1, p2, p3, m.matrix4_identity, mat);
}

triangle_tf :: proc(p1, p2, p3: m.Point, tf: m.Matrix4) -> Triangle {
    return triangle_tf_mat(p1, p2, p3, tf, material());
}

triangle_default :: proc(p1, p2, p3: m.Point) -> Triangle {
    return triangle_tf_mat(p1, p2, p3, m.matrix4_identity, material());
}

triangle :: proc {
    triangle_tf_mat,
    triangle_tf,
    triangle_mat,
    triangle_default,
}

@(private="file")
_triangle_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {
        t := transmute(^Triangle)s;
        return t.normal;
    },

    intersects = triangle_intersects,

    get_bounds = proc(s: ^Shape) -> Bounds {

        tri := transmute(^Triangle)s;

        minx := min(tri.p1.x, tri.p2.x, tri.p3.x);
        miny := min(tri.p1.y, tri.p2.y, tri.p3.y);
        minz := min(tri.p1.z, tri.p2.z, tri.p3.z);

        maxx := max(tri.p1.x, tri.p2.x, tri.p3.x);
        maxy := max(tri.p1.y, tri.p2.y, tri.p3.y);
        maxz := max(tri.p1.z, tri.p2.z, tri.p3.z);

        return bounds(minx, miny, minz, maxx, maxy, maxz);
    },

    eq = proc(a, b: ^Shape) -> bool { return true },
};

triangle_intersects :: proc(s: ^Shape, r: m.Ray, xs_buf: ^Intersection_Buffer) -> []Intersection {
    tri := transmute(^Triangle)s;

    dir_cross_e2 := m.cross(r.direction, tri.e2);
    det := m.dot(tri.e1, dir_cross_e2);

    if abs(det) < m.FLOAT_EPSILON do return {};

    f := 1.0 / det;

    p1_to_origin := m.sub(r.origin, tri.p1);
    u := f * m.dot(p1_to_origin, dir_cross_e2);

    if u < 0 || u > 1 do return {};

    origin_cross_e1 := m.cross(p1_to_origin, tri.e1);
    v := f * m.dot(r.direction, origin_cross_e1);

    if v < 0 || (u + v) > 1 do return {};

    t := f * m.dot(tri.e2, origin_cross_e1);
    append_xs(xs_buf, intersection(t, tri));
    return xs_buf.intersections[xs_buf.count - 1:xs_buf.count];
}

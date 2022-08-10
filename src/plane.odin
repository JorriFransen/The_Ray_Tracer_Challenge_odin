package raytracer

import m "raytracer:math"

Plane :: struct {
    using shape: Shape,
}

plane_default :: proc(sb: $T/^Shapes) -> ^Plane {
    return shape(sb, &sb.planes, m.matrix4_identity, material());
}

plane_tf_mat :: proc(sb: $t/^Shapes, tf: m.Matrix4, mat: Material) -> ^Plane {
    return shape(sb, &sb.planes, tf, mat);
}

plane_tf :: proc(sb: $t/^Shapes, tf: m.Matrix4) -> ^Plane {
    return shape(sb, &sb.planes, tf, default_material);
}

plane_mat :: proc(sb: $t/^Shapes, mat: Material) -> ^Plane {
    return shape(sb, &sb.planes, m.matrix4_identity, mat);
}

plane :: proc {
    plane_default,
    plane_tf_mat,
    plane_tf,
    plane_mat,
}

plane_normal_at :: proc(plane: ^Plane, p: m.Point) -> m.Vector {
    return m.vector(0, 1, 0);
}

plane_intersects_ray :: proc(p: ^Plane, r: m.Ray) -> Maybe(Intersection) {

    if abs(r.direction.y) < m.FLOAT_EPSILON do return nil;

    t := -r.origin.y / r.direction.y;

    return intersection(t, p);
}

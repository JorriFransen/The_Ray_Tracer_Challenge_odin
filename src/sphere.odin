package raytracer

import m "raytracer:math"

Sphere :: struct {
    using shape: Shape,
}

sphere_tf_mat :: proc(sb: $T/^Shapes, tf: m.Matrix4, mat: Material)-> ^Sphere {

    return shape(sb, &sb.spheres, tf, mat);
}

sphere_mat :: proc(sb: $T/^Shapes, mat: Material) -> ^Sphere {
    return sphere_tf_mat(sb, m.matrix4_identity, mat);
}

sphere_tf :: proc(sb: $T/^Shapes, tf: m.Matrix4) -> ^Sphere {
    return sphere_tf_mat(sb, tf, default_material);
}

sphere_default :: proc(sb: $T/^Shapes) -> ^Sphere {
    return sphere_tf_mat(sb, m.matrix4_identity, default_material);
}

sphere :: proc {
    sphere_tf_mat,
    sphere_mat,
    sphere_tf,
    sphere_default,
}

sphere_normal_at :: proc(s: ^Sphere, p: m.Point) -> m.Vector {

    return m.sub(p, m.point(0, 0, 0));
}

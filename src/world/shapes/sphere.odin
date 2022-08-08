package world_shapes

import m "raytracer:math"
import g "raytracer:graphics"

Sphere :: struct {
    using shape: Shape,
}

sphere_tf_mat :: proc(sb: ^Shapes($N), tf: m.Matrix4, mat: g.Material)-> ^Sphere {

    // spheres := &__shapes__.spheres;
    // assert(spheres.used < spheres.cap);
    // r := &spheres.buf[spheres.used];
    // spheres.used += 1;

    assert(sb.spheres.used < N);
    r := &sb.spheres.spheres[sb.spheres.used];
    sb.spheres.used += 1;


    set_transform(r, tf);
    set_material(r, mat);
    r.derived = r;
    return r;
}

sphere_mat :: proc(sb: ^Shapes($N), mat: g.Material) -> ^Sphere {
    return sphere_tf_mat(sb, m.matrix4_identity, mat);
}

sphere_tf :: proc(sb: ^Shapes($N), tf: m.Matrix4) -> ^Sphere {
    return sphere_tf_mat(sb, tf, g.default_material);
}

sphere_default :: proc(sb: ^Shapes($N)) -> ^Sphere {
    return sphere_tf_mat(sb, m.matrix4_identity, g.default_material);
}

sphere :: proc {
    sphere_tf_mat,
    sphere_mat,
    sphere_tf,
    sphere_default,
}

sphere_normal_at :: proc(s: ^Sphere, p: m.Point) -> m.Vector {

    op : m.Point = s.inverse_transform * p;
    on := m.sub(op, m.point(0, 0, 0));

    wn := m.matrix4_transpose(s.inverse_transform) * on;

    wn.w = 0;

    assert(m.is_vector(wn));
    return m.normalize(wn);
}

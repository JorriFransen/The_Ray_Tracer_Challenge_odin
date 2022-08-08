package raytracer

import "core:math"

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

sphere_intersect_ray :: proc(s: ^Sphere, r: m.Ray) -> Maybe([2]Intersection) {

    sphere_to_ray := m.sub(r.origin, m.point(0, 0, 0));

    a := m.dot(r.direction, r.direction);
    b := 2 * m.dot(r.direction, sphere_to_ray);
    c := m.dot(sphere_to_ray, sphere_to_ray) - 1;

    discriminant := (b * b) - 4 * a * c;

    if discriminant < 0 {
        return nil;
    }

    discriminant_sqrt := math.sqrt(discriminant);
    a2 := 2 * a;

    t1 := m.real((-b - discriminant_sqrt) / a2);
    t2 := m.real((-b + discriminant_sqrt) / a2);

    assert(t1 <= t2);

    return [?]Intersection { intersection(t1, s), intersection(t2, s) };
}

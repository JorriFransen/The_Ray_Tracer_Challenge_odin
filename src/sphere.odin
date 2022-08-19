package raytracer

import "core:math"
import m "raytracer:math"

Sphere :: struct {
    using shape: Shape,
}

sphere_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Sphere {
    return Sphere { shape(_sphere_vtable, tf, mat) };
}

sphere_mat :: proc(mat: Material) -> Sphere {
    return sphere_tf_mat(m.matrix4_identity, mat);
}

sphere_tf :: proc(tf: m.Matrix4) -> Sphere {
    return sphere_tf_mat(tf, material());
}

sphere_default :: proc() -> Sphere {
    return sphere_tf_mat(m.matrix4_identity, material());
}

sphere :: proc {
    sphere_tf_mat,
    sphere_tf,
    sphere_mat,
    sphere_default,
}

glass_sphere :: proc() -> Sphere {
    return sphere(material(transparency=1, refractive_index=1.5));
}

@(private="file")
_sphere_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {
        return m.sub(p, m.point(0, 0, 0));
    },

    intersects = proc(s: ^Shape, r: m.Ray) -> Maybe([2]Intersection) {

        t := start_timing("Sphere intersect");
        defer end_timing(&t);

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
    },

    eq = proc(a, b: ^Shape) -> bool { return true },
};


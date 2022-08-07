package tests_world

import "core:testing"
import "core:math"

import w "raytracer:world"
import g "raytracer:graphics"
import m "raytracer:math"

import r "raytracer:test_runner"

PI :: m.real(math.PI);

shape_suite := r.Test_Suite {
    name = "Shape/",
    tests = {
        r.test("S_Default_Transform ", S_Default_Transform),
        r.test("S_Modified_Transform", S_Modified_Transform),
        r.test("S_Scaled_Intersect_R", S_Scaled_Intersect_R),
        r.test("S_Normal_X_Axis", S_Normal_X_Axis),
        r.test("S_Normal_Y_Axis", S_Normal_Y_Axis),
        r.test("S_Normal_Z_Axis", S_Normal_Z_Axis),
        r.test("S_Normal_Nonaxial", S_Normal_Nonaxial),
        r.test("S_Normal_Normalized", S_Normal_Normalized),
        r.test("S_Translated_Normal", S_Translated_Normal),
        r.test("S_Scaled_Rotated_Normal", S_Scaled_Rotated_Normal),
        r.test("Sphere_Default_Material", Sphere_Default_Material),
        r.test("Sphere_Modified_Material", Sphere_Modified_Material),
    },
}

@test
S_Default_Transform :: proc(t: ^r.T) {

    s := w.sphere();

    expect(t, m.eq(s.inverse_transform, m.matrix4_identity));
}

@test
S_Modified_Transform :: proc(t: ^r.T) {

    tf := m.translation(2, 3, 4);
    tf_inv := m.matrix_inverse(tf);

    {
        s := w.sphere()

        w.shape_set_transform(&s, tf);

        expect(t, m.eq(s.inverse_transform, tf_inv));
    }

    {
        s := w.sphere(tf);

        expect(t, s.inverse_transform == tf_inv);
    }
}

@test
S_Scaled_Intersect_R :: proc(t: ^r.T) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    s := w.sphere(m.scaling(2, 2, 2));

    xs, ok := w.intersects(s, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 3);
    expect(t, xs[1].t == 7);

}

@test
S_Normal_X_Axis :: proc(t: ^r.T) {

    s := w.sphere();
    p := m.point(1, 0, 0);

    n := w.shape_normal_at(&s, p);
    n1 := w.sphere_normal_at(&s, p);

    expected := m.vector(1, 0, 0);

    expect(t, n == expected);
    expect(t, n1 == expected);
}

@test
S_Normal_Y_Axis :: proc(t: ^r.T) {

    s := w.sphere();
    p := m.point(0, 1, 0);

    n := w.shape_normal_at(&s, p);
    n1 := w.sphere_normal_at(&s, p);

    expected := m.vector(0, 1, 0);

    expect(t, n == expected);
    expect(t, n1 == expected);
}

@test
S_Normal_Z_Axis :: proc(t: ^r.T) {

    s := w.sphere();
    p := m.point(0, 0, 1);

    n := w.shape_normal_at(&s, p);
    n1 := w.sphere_normal_at(&s, p);

    expected := m.vector(0, 0, 1);

    expect(t, n == expected);
    expect(t, n1 == expected);
}

@test
S_Normal_Nonaxial :: proc(t: ^r.T) {

    s := w.sphere();

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := w.shape_normal_at(&s, p);
    n1:= w.sphere_normal_at(&s, p);

    expected := m.vector(v, v, v);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
S_Normal_Normalized :: proc(t: ^r.T) {

    s := w.sphere();

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := w.shape_normal_at(&s, p);
    n1 := w.sphere_normal_at(&s, p);

    expected := m.normalize(n);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
S_Translated_Normal :: proc(t: ^r.T) {

    s := w.sphere(m.translation(0, 1, 0));

    p := m.point(0, 1.70711, -0.70711);

    n := w.shape_normal_at(&s, p);
    n1 := w.sphere_normal_at(&s, p);

    expected := m.vector(0, 0.70711, -0.70711);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
S_Scaled_Rotated_Normal :: proc(t: ^r.T) {

    s := w.sphere(m.scaling(1, 0.5, 1) * m.rotation_z(PI / 5));

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;
    p := m.point(0, sqrt2_over_2, -sqrt2_over_2);

    n := w.shape_normal_at(&s, p);
    n1:= w.sphere_normal_at(&s, p);

    expected := m.vector(0, 0.97014, -0.24254);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
Sphere_Default_Material :: proc(t: ^r.T) {

    s := w.sphere();

    m := s.material;

    expect(t, m == g.material());
}

@test
Sphere_Modified_Material :: proc(t: ^r.T) {

    {
        s := w.sphere();
        m := g.material();
        m.ambient = 1;

        w.shape_set_material(&s, m);

        expect(t, s.material == m);
    }

    {
        m := g.material();
        m.ambient = 1;
        s := w.sphere(m);

        expect(t, s.material == m);
    }

    {
        s := w.sphere();
        m := g.material();
        m.ambient = 1;

        s.material = m;

        expect(t, s.material == m);
    }
}

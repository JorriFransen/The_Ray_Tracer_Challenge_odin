package tests

import "core:math"
import "core:testing"
import m "raytracer:math"

shape_suite := Test_Suite {
    name = "Shape/",
    tests = {
        test("S_Default_Transform ", S_Default_Transform),
        test("S_Modified_Transform", S_Modified_Transform),
        test("S_Scaled_Intersect_R", S_Scaled_Intersect_R),
        test("S_Normal_X_Axis", S_Normal_X_Axis),
        test("S_Normal_Y_Axis", S_Normal_Y_Axis),
        test("S_Normal_Z_Axis", S_Normal_Z_Axis),
        test("S_Normal_Nonaxial", S_Normal_Nonaxial),
        test("S_Normal_Normalized", S_Normal_Normalized),
        test("S_Translated_Normal", S_Translated_Normal),
        test("S_Scaled_Rotated_Normal", S_Scaled_Rotated_Normal),
    },
}

@test
S_Default_Transform :: proc(t: ^testing.T) {

    s := m.sphere();

    expect(t, s.transform == m.matrix4_identity);
}

@test
S_Modified_Transform :: proc(t: ^testing.T) {

    {
        s := m.sphere()
        tf := m.translation(2, 3, 4);

        m.shape_set_transform(&s, tf);

        expect(t, s.transform == tf);
    }

    {
        tf := m.translation(2, 3, 4);
        s := m.sphere(tf);

        expect(t, s.transform == tf);
    }
}

@test
S_Scaled_Intersect_R :: proc(t: ^testing.T) {

    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    s := m.sphere(m.scaling(2, 2, 2));

    xs, ok := m.intersects(s, r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 3);
    expect(t, xs[1].t == 7);

}

@test
S_Normal_X_Axis :: proc(t: ^testing.T) {

    s := m.sphere();
    p := m.point(1, 0, 0);

    n := m.shape_normal_at(&s, p);
    n1 := m.sphere_normal_at(&s, p);

    expected := m.vector(1, 0, 0);

    expect(t, n == expected);
    expect(t, n1 == expected);
}

@test
S_Normal_Y_Axis :: proc(t: ^testing.T) {

    s := m.sphere();
    p := m.point(0, 1, 0);

    n := m.shape_normal_at(&s, p);
    n1 := m.sphere_normal_at(&s, p);

    expected := m.vector(0, 1, 0);

    expect(t, n == expected);
    expect(t, n1 == expected);
}

@test
S_Normal_Z_Axis :: proc(t: ^testing.T) {

    s := m.sphere();
    p := m.point(0, 0, 1);

    n := m.shape_normal_at(&s, p);
    n1 := m.sphere_normal_at(&s, p);

    expected := m.vector(0, 0, 1);

    expect(t, n == expected);
    expect(t, n1 == expected);
}

@test
S_Normal_Nonaxial :: proc(t: ^testing.T) {

    s := m.sphere();

    v := math.sqrt(f32(3.0)) / 3;
    p := m.point(v, v, v);

    n := m.shape_normal_at(&s, p);
    n1:= m.sphere_normal_at(&s, p);

    expected := m.vector(v, v, v);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
S_Normal_Normalized :: proc(t: ^testing.T) {

    s := m.sphere();

    v := math.sqrt(f32(3.0)) / 3;
    p := m.point(v, v, v);

    n := m.shape_normal_at(&s, p);
    n1 := m.sphere_normal_at(&s, p);

    expected := m.normalize(n);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
S_Translated_Normal :: proc(t: ^testing.T) {

    s := m.sphere(m.translation(0, 1, 0));

    p := m.point(0, 1.70711, -0.70711);

    n := m.shape_normal_at(&s, p);
    n1 := m.sphere_normal_at(&s, p);

    expected := m.vector(0, 0.70711, -0.70711);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

@test
S_Scaled_Rotated_Normal :: proc(t: ^testing.T) {

    s := m.sphere(m.scaling(1, 0.5, 1) * m.rotation_z(PI / 5));

    sqrt2_over_2 := math.sqrt(m.Matrix_Element_Type(2.0)) / 2;
    p := m.point(0, sqrt2_over_2, -sqrt2_over_2);

    n := m.shape_normal_at(&s, p);
    n1:= m.sphere_normal_at(&s, p);

    expected := m.vector(0, 0.97014, -0.24254);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
}

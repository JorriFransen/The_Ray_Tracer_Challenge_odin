package tests_world

import w "raytracer:world"
import s "raytracer:world/shapes"
import g "raytracer:graphics"
import m "raytracer:math"

import r "raytracer:test_runner"

import "core:math"

PI :: m.real(math.PI);

shape_suite := r.Test_Suite {
    name = "Shape/",
    tests = {
        r.test("Default_Transform", Default_Transform),
        r.test("Assign_Transform", Assign_Transform),
        r.test("Default_Material", Default_Material),
        r.test("Assign_Material", Assign_Material),
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
Default_Transform :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    ts := s.test_shape(&sb);

    expect(t, m.eq(ts.inverse_transform, m.matrix4_identity));
}

@test
Assign_Transform :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    ts := s.test_shape(&sb);

    s.set_transform(ts, m.translation(2, 3, 4));

    expect(t, m.eq(ts.inverse_transform, m.matrix_inverse(m.translation(2, 3, 4))));
}

@test
Default_Material :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    ts := s.test_shape(&sb);

    expect(t, ts.material == g.material());
}

@test
Assign_Material :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(2);
    m := g.material(ambient = 1);

    {
        ts := s.test_shape(&sb);
        ts.material = m;
        expect(t, ts.material == m);
    }

    {
        ts := s.test_shape(&sb);
        s.set_material(ts, m);
        expect(t, ts.material == m);
    }

}

@test
S_Default_Transform :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    s := s.sphere(&sb);

    expect(t, m.eq(s.inverse_transform, m.matrix4_identity));
}

@test
S_Modified_Transform :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(2);

    tf := m.translation(2, 3, 4);
    tf_inv := m.matrix_inverse(tf);

    {
        sp := s.sphere(&sb);

        s.set_transform(sp, tf);

        expect(t, m.eq(sp.inverse_transform, tf_inv));
    }

    {
        sp := s.sphere(&sb, tf);

        expect(t, sp.inverse_transform == tf_inv);
    }
}

@test
S_Scaled_Intersect_R :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    sp := s.sphere(&sb, m.scaling(2, 2, 2));

    xs, ok := w.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 3);
    expect(t, xs[1].t == 7);

}

@test
S_Normal_X_Axis :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);

    sp := s.sphere(&sb);
    p := m.point(1, 0, 0);

    n := s.normal_at(sp, p);
    n1 := s.sphere_normal_at(sp, p);
    n2 := s.shape_normal_at(sp, p);

    expected := m.vector(1, 0, 0);

    expect(t, n == expected);
    expect(t, n1 == expected);
    expect(t, n2 == expected);
}

@test
S_Normal_Y_Axis :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);

    sp := s.sphere(&sb);
    p := m.point(0, 1, 0);

    n := s.shape_normal_at(sp, p);
    n1 := s.sphere_normal_at(sp, p);
    n2 := s.shape_normal_at(sp, p);

    expected := m.vector(0, 1, 0);

    expect(t, n == expected);
    expect(t, n1 == expected);
    expect(t, n2 == expected);
}

@test
S_Normal_Z_Axis :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);

    sp := s.sphere(&sb);
    p := m.point(0, 0, 1);

    n := s.shape_normal_at(sp, p);
    n1 := s.sphere_normal_at(sp, p);
    n2 := s.shape_normal_at(sp, p);

    expected := m.vector(0, 0, 1);

    expect(t, n == expected);
    expect(t, n1 == expected);
    expect(t, n2 == expected);
}

@test
S_Normal_Nonaxial :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);

    sp := s.sphere(&sb);

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := s.shape_normal_at(sp, p);
    n1:= s.sphere_normal_at(sp, p);
    n2:= s.shape_normal_at(sp, p);

    expected := m.vector(v, v, v);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
    expect(t, m.eq(n2, expected));
}

@test
S_Normal_Normalized :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);

    sp := s.sphere(&sb);

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := s.shape_normal_at(sp, p);
    n1 := s.sphere_normal_at(sp, p);
    n2 := s.shape_normal_at(sp, p);

    expected := m.normalize(n);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
    expect(t, m.eq(n2, expected));
}

@test
S_Translated_Normal :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    sp := s.sphere(&sb, m.translation(0, 1, 0));

    p := m.point(0, 1.70711, -0.70711);

    n := s.shape_normal_at(sp, p);
    n1 := s.sphere_normal_at(sp, p);
    n2 := s.shape_normal_at(sp, p);

    expected := m.vector(0, 0.70711, -0.70711);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
    expect(t, m.eq(n2, expected));
}

@test
S_Scaled_Rotated_Normal :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    sp := s.sphere(&sb, m.scaling(1, 0.5, 1) * m.rotation_z(PI / 5));

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;
    p := m.point(0, sqrt2_over_2, -sqrt2_over_2);

    n := s.shape_normal_at(sp, p);
    n1:= s.sphere_normal_at(sp, p);
    n2:= s.shape_normal_at(sp, p);

    expected := m.vector(0, 0.97014, -0.24254);

    expect(t, m.eq(n, expected));
    expect(t, m.eq(n1, expected));
    expect(t, m.eq(n2, expected));
}

@test
Sphere_Default_Material :: proc(t: ^r.Test_Context) {

    sb : s.Shapes(1);
    sp := s.sphere(&sb);

    m := sp.material;

    expect(t, m == g.material());
}

@test
Sphere_Modified_Material :: proc(t: ^r.Test_Context) {

    sb := s.shapes(2, context.temp_allocator);

    {
        sp := s.sphere(&sb);
        m := g.material();
        m.ambient = 1;

        s.set_material(sp, m);

        expect(t, sp.material == m);
    }

    assert(sb.spheres.current_block == &sb.spheres.first_block);

    {
        m := g.material();
        m.ambient = 1;
        sp := s.sphere(&sb, m);

        expect(t, sp.material == m);
    }

    {
        sp := s.sphere(&sb);
        m := g.material();
        m.ambient = 1;

        sp.material = m;

        expect(t, sp.material == m);
    }
}

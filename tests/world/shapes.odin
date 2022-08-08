package tests_world

import "core:math"

import rt "raytracer:."
import r "raytracer:test_runner"
import m "raytracer:math"

PI :: m.real(math.PI);

shape_suite := r.Test_Suite {
    name = "Shape/",
    tests = {
        r.test("Default_Transform", Default_Transform),
        r.test("Assign_Transform", Assign_Transform),
        r.test("Default_Material", Default_Material),
        r.test("Assign_Material", Assign_Material),
        r.test("Scaled_Intersect", Scaled_Intersect),
        r.test("Translated_Intersect", Translated_Intersect),
        r.test("Translated_Normal", Translated_Normal),
        r.test("Transformed_Normal", Transformed_Normal),

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

    sb : rt.Shapes(1);
    ts := rt.test_shape(&sb);

    expect(t, eq(ts.inverse_transform, m.matrix4_identity));
}

@test
Assign_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    ts := rt.test_shape(&sb);

    rt.set_transform(ts, m.translation(2, 3, 4));

    expect(t, eq(ts.inverse_transform, m.matrix_inverse(m.translation(2, 3, 4))));
}

@test
Default_Material :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    ts := rt.test_shape(&sb);

    expect(t, ts.material == rt.material());
}

@test
Assign_Material :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(2);
    m := rt.material(ambient = 1);

    {
        ts := rt.test_shape(&sb);
        ts.material = m;
        expect(t, ts.material == m);
    }

    {
        ts := rt.test_shape(&sb);
        rt.set_material(ts, m);
        expect(t, ts.material == m);
    }

}

@test
Scaled_Intersect :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    ts := rt.test_shape(&sb);
    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    rt.set_transform(ts, m.scaling(2, 2, 2));

    xs := rt.intersects(ts, r)

    expect(t, eq(ts.saved_ray.origin, m.point(0, 0, -2.5)));
    expect(t, eq(ts.saved_ray.direction, m.vector(0, 0, 0.5)));

}

@test
Translated_Intersect :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    ts := rt.test_shape(&sb);
    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    rt.set_transform(ts, m.translation(5, 0, 0));

    s := rt.intersects(ts, r);

    expect(t, eq(ts.saved_ray.origin, m.point(-5, 0, -5)));
    expect(t, eq(ts.saved_ray.direction, m.vector(0, 0, 1)));
}

@test
Translated_Normal :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    ts := rt.test_shape(&sb);

    rt.set_transform(ts, m.translation(0, 1, 0));
    n := rt.normal_at(ts, m.point(0, 1.70711, -0.70711));

    expect(t, eq(n, m.vector(0, 0.70711, -0.70711)));
}

@test
Transformed_Normal :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    ts := rt.test_shape(&sb);

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;

    rt.set_transform(ts, m.scaling(1, 0.5, 1) * m.rotation_z( PI / 5));
    n := rt.normal_at(ts, m.point(0, sqrt2_over_2, -sqrt2_over_2));

    expect(t, eq(n, m.vector(0, 0.97014, -0.24254)));
}


@test
S_Default_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    s := rt.sphere(&sb);

    expect(t, eq(s.inverse_transform, m.matrix4_identity));
}

@test
S_Modified_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(2);

    tf := m.translation(2, 3, 4);
    tf_inv := m.matrix_inverse(tf);

    {
        sp := rt.sphere(&sb);

        rt.set_transform(sp, tf);

        expect(t, eq(sp.inverse_transform, tf_inv));
    }

    {
        sp := rt.sphere(&sb, tf);

        expect(t, sp.inverse_transform == tf_inv);
    }
}

@test
S_Scaled_Intersect_R :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    sp := rt.sphere(&sb, m.scaling(2, 2, 2));

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 3);
    expect(t, xs[1].t == 7);

}

@test
S_Normal_X_Axis :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    sp := rt.sphere(&sb);
    p := m.point(1, 0, 0);

    n := rt.normal_at(sp, p);

    expected := m.vector(1, 0, 0);

    expect(t, n == expected);
}

@test
S_Normal_Y_Axis :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    sp := rt.sphere(&sb);
    p := m.point(0, 1, 0);

    n := rt.normal_at(sp, p);

    expected := m.vector(0, 1, 0);

    expect(t, n == expected);
}

@test
S_Normal_Z_Axis :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    sp := rt.sphere(&sb);
    p := m.point(0, 0, 1);

    n := rt.normal_at(sp, p);

    expected := m.vector(0, 0, 1);

    expect(t, n == expected);
}

@test
S_Normal_Nonaxial :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    sp := rt.sphere(&sb);

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := rt.normal_at(sp, p);

    expected := m.vector(v, v, v);

    expect(t, eq(n, expected));
}

@test
S_Normal_Normalized :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);

    sp := rt.sphere(&sb);

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := rt.normal_at(sp, p);

    expected := m.normalize(n);

    expect(t, eq(n, expected));
}

@test
S_Translated_Normal :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb, m.translation(0, 1, 0));

    p := m.point(0, 1.70711, -0.70711);

    n := rt.normal_at(sp, p);

    expected := m.vector(0, 0.70711, -0.70711);

    expect(t, eq(n, expected));
}

@test
S_Scaled_Rotated_Normal :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb, m.scaling(1, 0.5, 1) * m.rotation_z(PI / 5));

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;
    p := m.point(0, sqrt2_over_2, -sqrt2_over_2);

    n := rt.normal_at(sp, p);

    expected := m.vector(0, 0.97014, -0.24254);

    expect(t, eq(n, expected));
}

@test
Sphere_Default_Material :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    m := sp.material;

    expect(t, m == rt.material());
}

@test
Sphere_Modified_Material :: proc(t: ^r.Test_Context) {

    sb := rt.shapes(2, context.temp_allocator);

    {
        sp := rt.sphere(&sb);
        m := rt.material();
        m.ambient = 1;

        rt.set_material(sp, m);

        expect(t, sp.material == m);
    }

    assert(sb.spheres.current_block == &sb.spheres.first_block);

    {
        m := rt.material();
        m.ambient = 1;
        sp := rt.sphere(&sb, m);

        expect(t, sp.material == m);
    }

    {
        sp := rt.sphere(&sb);
        m := rt.material();
        m.ambient = 1;

        sp.material = m;

        expect(t, sp.material == m);
    }
}

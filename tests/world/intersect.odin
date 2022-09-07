package tests_world

import "core:math"

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

intersect_suite := r.Test_Suite {
    name = "Intersect/",
    tests = {

        r.test("R_Intersect_Sphere_2P", R_Intersect_Sphere_2P),
        r.test("R_Intersect_Sphere_Tangent", R_Intersect_Sphere_Tangent),
        r.test("R_Misses_Sphere", R_Misses_Sphere),
        r.test("R_Inside_Sphere", R_Inside_Sphere),
        r.test("R_Sphere_Behind", R_Sphere_Behind),
        r.test("Intersection_Constructor", Intersection_Constructor),
        r.test("Aggregating_Intersections", Aggregating_Intersections),
        r.test("Intersect_Sets_Ojb", Intersect_Sets_Ojb),
        r.test("Hit_All_Positive", Hit_All_Positive),
        r.test("Hit_Some_Negative", Hit_Some_Negative),
        r.test("Hit_All_Negative", Hit_All_Negative),
        r.test("Hit_Lowest_Non_Negative", Hit_Lowest_Non_Negative),
        r.test("Hit_Info", Hit_Info),
        r.test("Hit_Info_Outside", Hit_Info_Outside),
        r.test("Hit_Info_Inside", Hit_Info_Inside),
        r.test("Hit_Info_Over_Point", Hit_Info_Over_Point),
        r.test("Hit_Info_Reflection", Hit_Info_Reflection),
        r.test("Hit_Info_Refractive_Indices", Hit_Info_Refractive_Indices),
        r.test("Hit_Info_Under_Point", Hit_Info_Under_Point),
        r.test("Schlick_Total_Internal_Reflection", Schlick_Total_Internal_Reflection),
        r.test("Schlick_Perpendicular", Schlick_Perpendicular),
        r.test("Schlick_Low_Angle_n2_GT_n1", Schlick_Low_Angle_n2_GT_n1),
    },
}

@test
R_Intersect_Sphere_2P :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 4.0);
    expect(t, xs[1].t == 6.0);
}

@test
R_Intersect_Sphere_Tangent :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    ray := m.ray(m.point(0, 1, -5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 5.0);
    expect(t, xs[1].t == 5.0);
}

@test
R_Misses_Sphere :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    ray := m.ray(m.point(0, 2, -5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, !ok);
}

@test
R_Inside_Sphere :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -1.0);
    expect(t, xs[1].t == 1.0);
}

@test
R_Sphere_Behind :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    ray := m.ray(m.point(0, 0, 5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -6.0);
    expect(t, xs[1].t == -4.0);
}

@test
Intersection_Constructor :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    i := rt.intersection(3.5, &sp);

    expect(t, i.t == 3.5);
    expect(t, i.object == &sp);
}

@test
Aggregating_Intersections :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    i1 := rt.intersection(1, &sp);
    i2 := rt.intersection(2, &sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 1);
    expect(t, xs[1].t == 2);
}

@test
Intersect_Sets_Ojb :: proc(t: ^r.Test_Context) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    sp := rt.sphere();

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].object == &sp);
    expect(t, xs[1].object == &sp);
}


@test
Hit_All_Positive :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    i1 := rt.intersection(1, &sp);
    i2 := rt.intersection(2, &sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := rt.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i1);
}

@test
Hit_Some_Negative :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    i1 := rt.intersection(-1, &sp);
    i2 := rt.intersection(1, &sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := rt.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i2);
}

@test
Hit_All_Negative :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    i1 := rt.intersection(-2, &sp);
    i2 := rt.intersection(-1, &sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    _, i_ok := rt.hit(xs[:]).?;

    expect(t, !i_ok);
}

@test
Hit_Lowest_Non_Negative :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    i1 := rt.intersection(5, &sp);
    i2 := rt.intersection(7, &sp);
    i3 := rt.intersection(-3, &sp);
    i4 := rt.intersection(2, &sp);

    xs := rt.intersections(i1, i2);

    // Testing this overload, normally the call above would be 'intersections(i1, i2, i3, i4);'
    rt.intersections(&xs, i3, i4);
    defer delete(xs);

    i, i_ok := rt.hit(xs[:]).?;

    expect(t, i == i4);
}

@test
Hit_Info :: proc(t: ^r.Test_Context) {

    shape := rt.sphere();

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    i := rt.intersection(4, &shape);

    comps := rt.hit_info(i, ray, nil, nil);

    expect(t, comps.t == i.t);
    expect(t, comps.object == i.object);
    expect(t, eq(comps.point, m.point(0, 0, -1)));
    expect(t, eq(comps.eye_v, m.vector(0, 0, -1)));
    expect(t, eq(comps.normal_v, m.vector(0, 0, -1)));
}

@test
Hit_Info_Outside :: proc(t: ^r.Test_Context) {

    shape := rt.sphere();

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    i := rt.intersection(4, &shape);

    comps := rt.hit_info(i, ray, nil, nil);

    expect(t, comps.inside == false);
}

@test
Hit_Info_Inside :: proc(t: ^r.Test_Context) {

    shape := rt.sphere();

    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    i := rt.intersection(1, &shape);

    comps := rt.hit_info(i, ray, nil, nil);

    expect(t, comps.t == i.t);
    expect(t, comps.object == i.object);
    expect(t, eq(comps.point, m.point(0, 0, 1)));
    expect(t, eq(comps.eye_v, m.vector(0, 0, -1)));
    expect(t, eq(comps.normal_v, m.vector(0, 0, -1)));

    expect(t, comps.inside);
}

@test
Hit_Info_Over_Point :: proc(t: ^r.Test_Context) {

    shape := rt.sphere(m.translation(0, 0, 1));

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    i := rt.intersection(5, &shape);

    hit_info := rt.hit_info(i, ray, nil, nil);

    expect(t, hit_info.over_point.z < -m.FLOAT_EPSILON / 2);
    expect(t, hit_info.point.z > hit_info.over_point.z);
}

@test
Hit_Info_Reflection :: proc(t: ^r.Test_Context) {

    shape := rt.plane();

    sqrt_2 := math.sqrt(m.real(2));
    sqrt_2_d2 := sqrt_2 / 2.0;

    r := m.ray(m.point(0, 1, -1), m.vector(0, -sqrt_2_d2, sqrt_2_d2));
    i := rt.intersection(sqrt_2, &shape);

    comps := rt.hit_info(i, r, nil, nil);

    expect(t, eq(comps.reflect_v, m.vector(0, sqrt_2_d2, sqrt_2_d2)));
}

@test
Hit_Info_Refractive_Indices :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    A := rt.glass_sphere();
    rt.set_transform(&A, m.scaling(2, 2, 2));
    A.material.refractive_index = 1.5;

    B := rt.glass_sphere();
    rt.set_transform(&B, m.translation(0, 0, -0.25));
    B.material.refractive_index = 2.0;

    C := rt.glass_sphere();
    rt.set_transform(&C, m.translation(0, 0, 0.25));
    C.material.refractive_index = 2.5;

    r := m.ray(m.point(0, 0, -4), m.vector(0, 0, 1));

    xs := rt.intersections(
        rt.intersection(2, &A),
        rt.intersection(2.75, &B),
        rt.intersection(3.25, &C),
        rt.intersection(4.75, &B),
        rt.intersection(5.25, &C),
        rt.intersection(6, &A),
    );
    defer delete(xs);

    expect(t, len(xs) == 6);

    expected1 := [6]m.real { 1.0, 1.5, 2.0, 2.5, 2.5, 1.5 };
    expected2 := [6]m.real { 1.5, 2.0, 2.5, 2.5, 1.5, 1.0 };

    hi_mem := make([]^rt.Shape, 3, context.temp_allocator);

    for it, i in xs {
        comps := rt.hit_info(it, r, xs[:], hi_mem);

        expect(t, comps.n1 == expected1[i]);
        expect(t, comps.n2 == expected2[i]);
    }
}

@test
Hit_Info_Under_Point :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    shape := rt.glass_sphere();
    rt.set_transform(&shape, m.translation(0, 0, 1));

    i := rt.intersection(5, &shape);

    xs := rt.intersections(i);
    defer delete(xs);

    hi_mem := make([]^rt.Shape, 1, context.temp_allocator);

    comps := rt.hit_info(i, r, xs[:], hi_mem);

    expect(t, comps.under_point.z > m.FLOAT_EPSILON / 2);
    expect(t, comps.point.z < comps.under_point.z);
}

@test
Schlick_Total_Internal_Reflection :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    shape := rt.glass_sphere();

    sqrt_2 := math.sqrt(m.real(2));
    sqrt_2_d2 := sqrt_2 / 2.0;

    r := m.ray(m.point(0, 0, sqrt_2_d2), m.vector(0, 1, 0));

    xs := rt.intersections(
        rt.intersection(-sqrt_2_d2, &shape),
        rt.intersection(sqrt_2_d2, &shape),
    );
    defer delete(xs);

    hi_mem := make([]^rt.Shape, 1, context.temp_allocator);

    comps := rt.hit_info(xs[1], r, xs[:], hi_mem);
    reflectance := rt.schlick(&comps);

    expect(t, reflectance == 1.0);
}

@test
Schlick_Perpendicular :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    shape := rt.glass_sphere();
    r := m.ray(m.point(0, 0, 0), m.vector(0, 1, 0));

    xs := rt.intersections(
        rt.intersection(-1, &shape),
        rt.intersection(1, &shape),
    );
    defer delete(xs);

    hi_mem := make([]^rt.Shape, 1, context.temp_allocator);

    comps := rt.hit_info(xs[1], r, xs[:], hi_mem);
    reflectance := rt.schlick(&comps);

    expect(t, eq(reflectance, 0.04));
}

@test
Schlick_Low_Angle_n2_GT_n1 :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    shape := rt.glass_sphere();
    r := m.ray(m.point(0, 0.99, -2), m.vector(0, 0, 1));

    xs := rt.intersections(rt.intersection(1.8589, &shape));
    defer delete(xs);

    hi_mem := make([]^rt.Shape, 1, context.temp_allocator);

    comps := rt.hit_info(xs[0], r, xs[:], hi_mem);
    reflectance := rt.schlick(&comps);

    expect(t, eq(reflectance, 0.48873));
}

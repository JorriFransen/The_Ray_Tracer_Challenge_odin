package tests_world

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
        r.test("Hit_Info_Point_Offset", Hit_Info_Point_Offset),
    },
}

@test
R_Intersect_Sphere_2P :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 4.0);
    expect(t, xs[1].t == 6.0);
}

@test
R_Intersect_Sphere_Tangent :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);
    ray := m.ray(m.point(0, 1, -5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 5.0);
    expect(t, xs[1].t == 5.0);
}

@test
R_Misses_Sphere :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);
    ray := m.ray(m.point(0, 2, -5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, !ok);
}

@test
R_Inside_Sphere :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);
    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -1.0);
    expect(t, xs[1].t == 1.0);
}

@test
R_Sphere_Behind :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);
    ray := m.ray(m.point(0, 0, 5), m.vector(0, 0, 1));

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -6.0);
    expect(t, xs[1].t == -4.0);
}

@test
Intersection_Constructor :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    i := rt.intersection(3.5, sp);

    expect(t, i.t == 3.5);
    expect(t, i.object == sp);
}

@test
Aggregating_Intersections :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    i1 := rt.intersection(1, sp);
    i2 := rt.intersection(2, sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 1);
    expect(t, xs[1].t == 2);
}

@test
Intersect_Sets_Ojb :: proc(t: ^r.Test_Context) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    xs, ok := rt.intersects(sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].object == sp);
    expect(t, xs[1].object == sp);
}


@test
Hit_All_Positive :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    i1 := rt.intersection(1, sp);
    i2 := rt.intersection(2, sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := rt.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i1);
}

@test
Hit_Some_Negative :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    i1 := rt.intersection(-1, sp);
    i2 := rt.intersection(1, sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := rt.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i2);
}

@test
Hit_All_Negative :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    i1 := rt.intersection(-2, sp);
    i2 := rt.intersection(-1, sp);

    xs := rt.intersections(i1, i2);
    defer delete(xs);

    _, i_ok := rt.hit(xs[:]).?;

    expect(t, !i_ok);
}

@test
Hit_Lowest_Non_Negative :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    sp := rt.sphere(&sb);

    i1 := rt.intersection(5, sp);
    i2 := rt.intersection(7, sp);
    i3 := rt.intersection(-3, sp);
    i4 := rt.intersection(2, sp);

    xs := rt.intersections(i1, i2);

    // Testing this overload, normally the call above would be 'intersections(i1, i2, i3, i4);'
    rt.intersections(&xs, i3, i4);
    defer delete(xs);

    i, i_ok := rt.hit(xs[:]).?;

    expect(t, i == i4);
}

@test
Hit_Info :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    i := rt.intersection(4, shape);

    comps := rt.hit_info(i, ray);

    expect(t, comps.t == i.t);
    expect(t, comps.object == i.object);
    expect(t, eq(comps.point, m.point(0, 0, -1)));
    expect(t, eq(comps.eye_v, m.vector(0, 0, -1)));
    expect(t, eq(comps.normal_v, m.vector(0, 0, -1)));
}

@test
Hit_Info_Outside :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    i := rt.intersection(4, shape);

    comps := rt.hit_info(i, ray);

    expect(t, comps.inside == false);
}

@test
Hit_Info_Inside :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb);

    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    i := rt.intersection(1, shape);

    comps := rt.hit_info(i, ray);

    expect(t, comps.t == i.t);
    expect(t, comps.object == i.object);
    expect(t, eq(comps.point, m.point(0, 0, 1)));
    expect(t, eq(comps.eye_v, m.vector(0, 0, -1)));
    expect(t, eq(comps.normal_v, m.vector(0, 0, -1)));

    expect(t, comps.inside);
}

@test
Hit_Info_Point_Offset :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb, m.translation(0, 0, 1));

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    i := rt.intersection(5, shape);

    hit_info := rt.hit_info(i, ray);

    expect(t, hit_info.over_point.z < -m.OVER_POINT_EPSILON / 2);
    expect(t, hit_info.point.z > hit_info.over_point.z);
}

package tests_world

import "core:testing"

import w "raytracer:world"
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
R_Intersect_Sphere_2P :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    s := w.sphere();

    xs, ok := w.intersects(s, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 4.0);
    expect(t, xs[1].t == 6.0);
}

@test
R_Intersect_Sphere_Tangent :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 1, -5), m.vector(0, 0, 1));
    s := w.sphere();

    xs, ok := w.intersects(s, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 5.0);
    expect(t, xs[1].t == 5.0);
}

@test
R_Misses_Sphere :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 2, -5), m.vector(0, 0, 1));
    s := w.sphere();

    xs, ok := w.intersects(s, ray).?;

    expect(t, !ok);
}

@test
R_Inside_Sphere :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    s := w.sphere();

    xs, ok := w.intersects(s, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -1.0);
    expect(t, xs[1].t == 1.0);
}

@test
R_Sphere_Behind :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, 5), m.vector(0, 0, 1));
    s := w.sphere();

    xs, ok := w.intersects(s, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -6.0);
    expect(t, xs[1].t == -4.0);
}

@test
Intersection_Constructor :: proc(t: ^testing.T) {

    s := w.sphere();

    i := w.intersection(3.5, s);

    expect(t, i.t == 3.5);
    expect(t, i.object == s);
}

@test
Aggregating_Intersections :: proc(t: ^testing.T) {

    s := w.sphere();
    i1 := w.intersection(1, s);
    i2 := w.intersection(2, s);

    xs := w.intersections(i1, i2);
    defer delete(xs);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 1);
    expect(t, xs[1].t == 2);
}

@test
Intersect_Sets_Ojb :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    s := w.sphere();

    xs, ok := w.intersects(s, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].object == s);
    expect(t, xs[1].object == s);
}


@test
Hit_All_Positive :: proc(t: ^testing.T) {

    s := w.sphere();
    i1 := w.intersection(1, s);
    i2 := w.intersection(2, s);

    xs := w.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := w.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i1);
}

@test
Hit_Some_Negative :: proc(t: ^testing.T) {

    s := w.sphere();
    i1 := w.intersection(-1, s);
    i2 := w.intersection(1, s);

    xs := w.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := w.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i2);
}

@test
Hit_All_Negative :: proc(t: ^testing.T) {

    s := w.sphere();
    i1 := w.intersection(-2, s);
    i2 := w.intersection(-1, s);

    xs := w.intersections(i1, i2);
    defer delete(xs);

    _, i_ok := w.hit(xs[:]).?;

    expect(t, !i_ok);
}

@test
Hit_Lowest_Non_Negative :: proc(t: ^testing.T) {

    s := w.sphere();
    i1 := w.intersection(5, s);
    i2 := w.intersection(7, s);
    i3 := w.intersection(-3, s);
    i4 := w.intersection(2, s);

    xs := w.intersections(i1, i2);

    // Testing this overload, normally the call above would be 'intersections(i1, i2, i3, i4);'
    w.intersections(&xs, i3, i4);
    defer delete(xs);

    i, i_ok := w.hit(xs[:]).?;

    expect(t, i == i4);
}

@test
Hit_Info :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    shape := w.sphere();
    i := w.intersection(4, shape);

    comps := w.hit_info(i, ray);

    expect(t, comps.t == i.t);
    expect(t, comps.object == i.object);
    expect(t, m.eq(comps.point, m.point(0, 0, -1)));
    expect(t, m.eq(comps.eye_v, m.vector(0, 0, -1)));
    expect(t, m.eq(comps.normal_v, m.vector(0, 0, -1)));
}

@test
Hit_Info_Outside :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    shape := w.sphere();
    i := w.intersection(4, shape);

    comps := w.hit_info(i, ray);

    expect(t, comps.inside == false);
}

@test
Hit_Info_Inside :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    shape := w.sphere();
    i := w.intersection(1, shape);

    comps := w.hit_info(i, ray);

    expect(t, comps.t == i.t);
    expect(t, comps.object == i.object);
    expect(t, m.eq(comps.point, m.point(0, 0, 1)));
    expect(t, m.eq(comps.eye_v, m.vector(0, 0, -1)));
    expect(t, m.eq(comps.normal_v, m.vector(0, 0, -1)));

    expect(t, comps.inside);
}

@test
Hit_Info_Point_Offset :: proc(t: ^testing.T) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    shape := w.sphere(m.translation(0, 0, 1));
    i := w.intersection(5, shape);

    hit_info := w.hit_info(i, ray);

    expect(t, hit_info.over_point.z < -m.OVER_POINT_EPSILON / 2);
    expect(t, hit_info.point.z > hit_info.over_point.z);
}

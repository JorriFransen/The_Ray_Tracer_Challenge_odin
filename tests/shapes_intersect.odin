package tests

import "core:testing"

import rm "raytracer:math"
import "raytracer:shapes"

intersect_suite := Test_Suite {
    name = "Intersect/",
    tests = {

        test("R_Intersect_Sphere_2P", R_Intersect_Sphere_2P),
        test("R_Intersect_Sphere_Tangent", R_Intersect_Sphere_Tangent),
        test("R_Misses_Sphere", R_Misses_Sphere),
        test("R_Inside_Sphere", R_Inside_Sphere),
        test("R_Sphere_Behind", R_Sphere_Behind),
        test("Intersection_Constructor", Intersection_Constructor),
        test("Aggregating_Intersections", Aggregating_Intersections),
        test("Intersect_Sets_Ojb", Intersect_Sets_Ojb),
        test("Hit_All_Positive", Hit_All_Positive),
        test("Hit_Some_Negative", Hit_Some_Negative),
        test("Hit_All_Negative", Hit_All_Negative),
        test("Hit_Lowest_Non_Negative", Hit_Lowest_Non_Negative),
    },
}

@test
R_Intersect_Sphere_2P :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, -5), rm.vector(0, 0, 1));
    s := shapes.sphere();

    xs, ok := shapes.intersects(s, r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 4.0);
    expect(t, xs[1].t == 6.0);
}

@test
R_Intersect_Sphere_Tangent :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 1, -5), rm.vector(0, 0, 1));
    s := shapes.sphere();

    xs, ok := shapes.intersects(s, r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 5.0);
    expect(t, xs[1].t == 5.0);
}

@test
R_Misses_Sphere :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 2, -5), rm.vector(0, 0, 1));
    s := shapes.sphere();

    xs, ok := shapes.intersects(s, r).?;

    expect(t, !ok);
}

@test
R_Inside_Sphere :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, 0), rm.vector(0, 0, 1));
    s := shapes.sphere();

    xs, ok := shapes.intersects(s, r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -1.0);
    expect(t, xs[1].t == 1.0);
}

@test
R_Sphere_Behind :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, 5), rm.vector(0, 0, 1));
    s := shapes.sphere();

    xs, ok := shapes.intersects(s, r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -6.0);
    expect(t, xs[1].t == -4.0);
}

@test
Intersection_Constructor :: proc(t: ^testing.T) {

    s := shapes.sphere();

    i := shapes.intersection(3.5, s);

    expect(t, i.t == 3.5);
    expect(t, i.object == s);
}

@test
Aggregating_Intersections :: proc(t: ^testing.T) {

    s := shapes.sphere();
    i1 := shapes.intersection(1, s);
    i2 := shapes.intersection(2, s);

    xs := shapes.intersections(i1, i2);
    defer delete(xs);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 1);
    expect(t, xs[1].t == 2);
}

@test
Intersect_Sets_Ojb :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, -5), rm.vector(0, 0, 1));

    s := shapes.sphere();

    xs, ok := shapes.intersects(s, r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].object == s);
    expect(t, xs[1].object == s);
}


@test
Hit_All_Positive :: proc(t: ^testing.T) {

    s := shapes.sphere();
    i1 := shapes.intersection(1, s);
    i2 := shapes.intersection(2, s);

    xs := shapes.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := shapes.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i1);
}

@test
Hit_Some_Negative :: proc(t: ^testing.T) {

    s := shapes.sphere();
    i1 := shapes.intersection(-1, s);
    i2 := shapes.intersection(1, s);

    xs := shapes.intersections(i1, i2);
    defer delete(xs);

    i, i_ok := shapes.hit(xs[:]).?;

    expect(t, i_ok);
    expect(t, i == i2);
}

@test
Hit_All_Negative :: proc(t: ^testing.T) {

    s := shapes.sphere();
    i1 := shapes.intersection(-2, s);
    i2 := shapes.intersection(-1, s);

    xs := shapes.intersections(i1, i2);
    defer delete(xs);

    _, i_ok := shapes.hit(xs[:]).?;

    expect(t, !i_ok);
}

@test
Hit_Lowest_Non_Negative :: proc(t: ^testing.T) {

    s := shapes.sphere();
    i1 := shapes.intersection(5, s);
    i2 := shapes.intersection(7, s);
    i3 := shapes.intersection(-3, s);
    i4 := shapes.intersection(2, s);

    xs := shapes.intersections(i1, i2);

    // Testing this overload, normally the call above would be 'intersections(i1, i2, i3, i4);'
    xs = shapes.intersections(xs, i3, i4);
    defer delete(xs);

    i, i_ok := shapes.hit(xs[:]).?;

    expect(t, i == i4);
}


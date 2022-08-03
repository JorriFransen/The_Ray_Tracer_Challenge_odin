package tests

import "core:testing"
import rm "raytracer:math"

ray_suite := Test_Suite {
    name = "Ray/",
    tests = {
        test("R_Construction", R_Construction),
        test("R_Distance_Along_Is_P", R_Distance_Along_Is_P),
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
R_Construction :: proc(t: ^testing.T) {

    origin := rm.point(1, 2, 3);
    direction := rm.vector(4, 5, 6);

    r := rm.ray(origin, direction);

    expect(t, r.origin == origin);
    expect(t, r.direction == direction);
}

@test
R_Distance_Along_Is_P :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(2, 3, 4), rm.vector(1, 0, 0));

    expect(t, rm.eq(rm.position(r, 0), rm.point(2, 3, 4)));
    expect(t, rm.eq(rm.position(r, 1), rm.point(3, 3, 4)));
    expect(t, rm.eq(rm.position(r, -1), rm.point(1, 3, 4)));
    expect(t, rm.eq(rm.position(r, 2.5), rm.point(4.5, 3, 4)));
}

@test
R_Intersect_Sphere_2P :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, -5), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersect(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 4.0);
    expect(t, xs[1].t == 6.0);
}

@test
R_Intersect_Sphere_Tangent :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 1, -5), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersect(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 5.0);
    expect(t, xs[1].t == 5.0);
}

@test
R_Misses_Sphere :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 2, -5), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersect(s, r);

    expect(t, len(xs) == 0);
}

@test
R_Inside_Sphere :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, 0), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersect(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -1.0);
    expect(t, xs[1].t == 1.0);
}

@test
R_Sphere_Behind :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, 5), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersect(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == -6.0);
    expect(t, xs[1].t == -4.0);
}

@test
Intersection_Constructor :: proc(t: ^testing.T) {

    s := rm.sphere();

    i := rm.intersection(3.5, s);

    expect(t, i.t == 3.5);
    expect(t, i.object == s);
}

@test
Aggregating_Intersections :: proc(t: ^testing.T) {

    s := rm.sphere();
    i1 := rm.intersection(1, s);
    i2 := rm.intersection(2, s);

    xs := rm.intersections(i1, i2);

    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 1);
    expect(t, xs[1].t == 2);
}

@test
Intersect_Sets_Ojb :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, -5), rm.vector(0, 0, 1));

    s := rm.sphere();

    {
        s2 := rm.sphere();
        expect(t, s != s2);
    }

    xs := rm.intersect(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0].object == s);
    expect(t, xs[1].object == s);
}


@test
Hit_All_Positive :: proc(t: ^testing.T) {
    s := rm.sphere();
    i1 := rm.intersection(1, s);
    i2 := rm.intersection(2, s);
    xs := rm.intersections(i1, i2);

    i := rm.hit(xs);

    expect(t, i == i1);
}

@test
Hit_Some_Negative :: proc(t: ^testing.T) {
    s := rm.sphere();
    i1 := rm.intersection(-1, s);
    i2 := rm.intersection(1, s);
    xs := rm.intersections(i1, i2);

    i := rm.hit(xs);

    expect(t, i == i2);
}

@test
Hit_All_Negative :: proc(t: ^testing.T) {
    s := rm.sphere();
    i1 := rm.intersection(-2, s);
    i2 := rm.intersection(-1, s);
    xs := rm.intersections(i1, i2);

    i := rm.hit(xs);

    expect(t, i.t == 0.0);
    expect(t, i.object == rm.Sphere { 0 });
}

@test
Hit_Lowest_Non_Negative :: proc(t: ^testing.T) {

    s := rm.sphere();
    i1 := rm.intersection(5, s);
    i2 := rm.intersection(7, s);
    i3 := rm.intersection(-3, s);
    i4 := rm.intersection(2, s);
    xs := rm.intersections(i1, i2, i3, i4);

    i := rm.hit(xs);

    expect(t, i == i4);
}

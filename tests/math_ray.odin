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

    xs := rm.intersects(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0] == 4.0);
    expect(t, xs[1] == 6.0);
}

@test
R_Intersect_Sphere_Tangent :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 1, -5), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersects(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0] == 5.0);
    expect(t, xs[1] == 5.0);

    delete(xs);
}

@test
R_Misses_Sphere :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 2, -5), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersects(s, r);

    expect(t, len(xs) == 0);
}

@test
R_Inside_Sphere :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(0, 0, 0), rm.vector(0, 0, 1));
    s := rm.sphere();

    xs := rm.intersects(s, r);

    expect(t, len(xs) == 2);
    expect(t, xs[0] == -1.0);
    expect(t, xs[1] == 1.0);
}

@test
R_Sphere_Behind :: proc(t: ^testing.T) {
}

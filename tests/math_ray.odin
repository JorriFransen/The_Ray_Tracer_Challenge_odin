package tests

import "core:testing"
import rm "raytracer:math"

ray_suite := Test_Suite {
    name = "Ray/",
    tests = {
        test("R_Construction", R_Construction),
        test("R_Distance_Along_Is_P", R_Distance_Along_Is_P),
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

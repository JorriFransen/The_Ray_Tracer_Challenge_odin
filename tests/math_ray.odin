package tests

import "core:testing"
import rm "raytracer:math"
import shapes "raytracer:shapes"

ray_suite := Test_Suite {
    name = "Ray/",
    tests = {
        test("R_Construction", R_Construction),
        test("R_Distance_Along_Is_P", R_Distance_Along_Is_P),
        test("R_Translation", R_Translation),
        test("R_Scaling", R_Scaling),
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

    expect(t, rm.eq(rm.ray_position(r, 0), rm.point(2, 3, 4)));
    expect(t, rm.eq(rm.ray_position(r, 1), rm.point(3, 3, 4)));
    expect(t, rm.eq(rm.ray_position(r, -1), rm.point(1, 3, 4)));
    expect(t, rm.eq(rm.ray_position(r, 2.5), rm.point(4.5, 3, 4)));
}

@test
R_Translation :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(1, 2, 3), rm.vector(0, 1, 0));
    m := rm.translation(3, 4, 5);

    r2 := rm.ray_transform(r, m);

    expect(t, r2.origin == rm.point(4, 6, 8));
    expect(t, r2.direction == rm.vector(0, 1, 0));
}

@test
R_Scaling :: proc(t: ^testing.T) {

    r := rm.ray(rm.point(1, 2, 3), rm.vector(0, 1, 0));
    m := rm.scaling(2, 3, 4);

    r2 := rm.ray_transform(r, m);

    expect(t, r2.origin == rm.point(2, 6, 12));
    expect(t, r2.direction == rm.vector(0, 3, 0));
}

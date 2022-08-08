package tests_math

import "core:testing"
import rm "raytracer:math"
import w "raytracer:world"

import r "raytracer:test_runner"

ray_suite := r.Test_Suite {
    name = "Ray/",
    tests = {
        r.test("R_Construction", R_Construction),
        r.test("R_Distance_Along_Is_P", R_Distance_Along_Is_P),
        r.test("R_Translation", R_Translation),
        r.test("R_Scaling", R_Scaling),
    },
}

@test
R_Construction :: proc(t: ^r.Test_Context) {

    origin := rm.point(1, 2, 3);
    direction := rm.vector(4, 5, 6);

    ray := rm.ray(origin, direction);

    r.expect(t, ray.origin == origin);
    r.expect(t, ray.direction == direction);
}

@test
R_Distance_Along_Is_P :: proc(t: ^r.Test_Context) {

    ray := rm.ray(rm.point(2, 3, 4), rm.vector(1, 0, 0));

    r.expect(t, rm.eq(rm.ray_position(ray, 0), rm.point(2, 3, 4)));
    r.expect(t, rm.eq(rm.ray_position(ray, 1), rm.point(3, 3, 4)));
    r.expect(t, rm.eq(rm.ray_position(ray, -1), rm.point(1, 3, 4)));
    r.expect(t, rm.eq(rm.ray_position(ray, 2.5), rm.point(4.5, 3, 4)));
}

@test
R_Translation :: proc(t: ^r.Test_Context) {

    ray := rm.ray(rm.point(1, 2, 3), rm.vector(0, 1, 0));
    m := rm.translation(3, 4, 5);

    ray2 := rm.ray_transform(ray, m);

    r.expect(t, ray2.origin == rm.point(4, 6, 8));
    r.expect(t, ray2.direction == rm.vector(0, 1, 0));
}

@test
R_Scaling :: proc(t: ^r.Test_Context) {

    ray := rm.ray(rm.point(1, 2, 3), rm.vector(0, 1, 0));
    m := rm.scaling(2, 3, 4);

    ray2 := rm.ray_transform(ray, m);

    r.expect(t, ray2.origin == rm.point(2, 6, 12));
    r.expect(t, ray2.direction == rm.vector(0, 3, 0));
}

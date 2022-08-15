package tests

import "core:math"

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

noise_suite := r.Test_Suite {
    name = "Simplex/",
    tests = {
        r.test("P1", P1),
    },
}

import "core:fmt"

@test
P1 :: proc(t: ^r.Test_Context) {

    resolution := 300;
    step_size := 1.0 / m.real(resolution);

    c := rt.canvas(resolution, resolution);
    defer rt.canvas_destroy(&c);

    // tf := m.translation(.5, 0, 0) * m.scaling(2, 1.5, 1) * m.rotation_z(math.PI / 8);
    tf := m.matrix4_identity;

    for y in 0..<resolution {

        for x in 0..<resolution {

            p := m.point(m.real(x) * step_size, m.real(y) * step_size, 0.06);

            vn := m.value_noise_3D(p, 8);
            col := rt.WHITE * vn;

            rt.canvas_write_pixel(c, x, resolution - 1 - y, col);
        }
    }



    // rt.display(c, "Noise test");

    // s := m.simplex(1.1, 2.2, -3.3);

    // fmt.printf("simplex(1.1, 2.2, -3.3): %v\n", s);

}

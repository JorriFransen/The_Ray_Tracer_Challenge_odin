package tests

import "core:math"
import "core:os"

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

noise_suite := r.Test_Suite {
    name = "Noise/",
    tests = {
        r.test("Value", Value),
        r.test("Perlin", Perlin),
    },
}

import "core:fmt"

@test
Value :: proc(t: ^r.Test_Context) {

    resolution := 200;
    step_size := 1.0 / m.real(resolution);

    c := rt.canvas(resolution, resolution);
    defer rt.canvas_destroy(&c);

    for o in 1..=8 {

        for y in 0..<resolution {
            for x in 0..<resolution {

                p := m.point(m.real(x) * step_size, m.real(y) * step_size, 0.06);

                vn := m.noise_sum(m.value_noise_3D, p, 3, o) * 0.5 + 0.5;
                col := rt.WHITE * vn;

                rt.canvas_write_pixel(c, x, resolution - 1 - y, col);
            }
        }

        // rt.display(c, "Value noise");

        // ppm := rt.ppm_from_canvas(c);
        // defer delete(ppm);

        // name := fmt.tprintf("images/noise/value_octave_%v.ppm", o);
        // if !rt.ppm_write_to_file(name, ppm) {
        //     fmt.fprintf(os.stderr, "Failed to write image: '%v'\n", name);
        // }

        // rt.canvas_clear(&c);
    }

}

@test
Perlin :: proc(t: ^r.Test_Context) {

    resolution := 200;
    step_size := 1.0 / m.real(resolution);

    c := rt.canvas(resolution, resolution);
    defer rt.canvas_destroy(&c);

    for o in 1..=8 {

        for y in 0..<resolution {
            for x in 0..<resolution {

                p := m.point(m.real(x) * step_size, m.real(y) * step_size, 0.06);

                vn := m.noise_sum(m.perlin_noise_3D, p, 3, o) * 0.5 + 0.5;
                col := rt.WHITE * vn;

                rt.canvas_write_pixel(c, x, resolution - 1 - y, col);
            }
        }

        rt.display(c, "Perlin noise");

        ppm := rt.ppm_from_canvas(c);
        defer delete(ppm);

        name := fmt.tprintf("images/noise/perlin_octave_%v.ppm", o);
        if !rt.ppm_write_to_file(name, ppm) {
            fmt.fprintf(os.stderr, "Failed to write image: '%v'\n", name);
        }

        rt.canvas_clear(&c);
    }


}

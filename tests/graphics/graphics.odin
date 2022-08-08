package tests_graphics

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

eq :: rt.eq;
expect :: r.expect;

graphics_suite := r.Test_Suite {
    name = "GFX/",
    tests = {
    },

    child_suites = {
        &color_suite,
        &canvas_suite,
        &material_suite,
        &light_suite,
    },
}

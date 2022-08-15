package tests_math

import r "raytracer:test_runner"

import rt "raytracer:."
import m "raytracer:math"

eq :: rt.eq;

math_suite := r.Test_Suite {
    name = "Math/",
    tests = { },
    child_suites = {
        &vec_suite,
        &matrix_suite,
        &transform_suite,
        &ray_suite,
    },
}


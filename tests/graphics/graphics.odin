package tests_graphics

import "core:testing"

import g "raytracer:graphics"
import m "raytracer:math"

import r "../runner"

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

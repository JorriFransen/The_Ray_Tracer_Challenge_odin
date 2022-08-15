package tests_graphics

import rt "raytracer:."
import m "raytracer:math"

import r "raytracer:test_runner"

material_suite := r.Test_Suite {
    name = "Mat/",
    tests = {
        r.test("Material_Constructor_Default", Material_Constructor_Default)
    },
}

@test
Material_Constructor_Default :: proc(t: ^r.Test_Context) {

    mat := rt.material();

    expect(t, eq(mat.color, rt.color(1, 1, 1)));
    expect(t, eq(mat.ambient, 0.1));
    expect(t, eq(mat.diffuse, 0.9));
    expect(t, eq(mat.specular, 0.9));
    expect(t, eq(mat.shininess, 200));
}

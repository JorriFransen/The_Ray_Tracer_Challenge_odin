package tests_graphics

import rt "raytracer:."
import m "raytracer:math"

import r "raytracer:test_runner"

material_suite := r.Test_Suite {
    name = "Mat/",
    tests = {
        r.test("Material_Constructor_Default", Material_Constructor_Default),
        r.test("Ligting_With_Pattern", Ligting_With_Pattern),
    },
}

@test
Material_Constructor_Default :: proc(t: ^r.Test_Context) {

    mat := rt.material();

    expect(t, eq(mat.color, rt.color(1, 1, 1)));
    expect(t, mat.ambient == 0.1);
    expect(t, mat.diffuse == 0.9);
    expect(t, mat.specular == 0.9);
    expect(t, mat.shininess == 200);
    expect(t, mat.reflective == 0);
}

@test
Ligting_With_Pattern :: proc(t: ^r.Test_Context) {

    mat := rt.material(ambient=1, diffuse=0, specular=0);
    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);
    mat.pattern = &pattern;

    obj := rt.sphere(mat);

    eye_v := m.vector(0, 0, -1);
    normal_v := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 0, -10), rt.WHITE);

    c1 := rt.lighting(&obj, light, m.point(0.9, 0, 0), eye_v, normal_v, false);
    c2 := rt.lighting(&obj, light, m.point(1.1, 0, 0), eye_v, normal_v, false);

    expect(t, eq(c1, rt.WHITE));
    expect(t, eq(c2, rt.BLACK));
}

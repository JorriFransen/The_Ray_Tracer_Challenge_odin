package tests;

import "core:testing"

import g "raytracer:graphics"
import m "raytracer:math"

graphics_suite := Test_Suite {
    name = "GFX/",
    tests = {

        test("Point_Light_Constructor", Point_Light_Constructor),

        test("Material_Constructor_Default", Material_Constructor_Default)
    },

    child_suites = {
        &color_suite,
        &canvas_suite,
    },
}

@test
Point_Light_Constructor :: proc(t: ^testing.T) {

    intensity := g.color(1, 1, 1);
    position := m.point(0, 0, 0);

    light := g.point_light(position, intensity);

    expect(t, m.eq(light.position, position));
    expect(t, m.eq(light.intensity, intensity));
}

@test
Material_Constructor_Default :: proc(t: ^testing.T) {

    mat := g.material();

    expect(t, m.eq(mat.color, g.color(1, 1, 1)));
    expect(t, m.eq(mat.ambient, 0.1));
    expect(t, m.eq(mat.diffuse, 0.9));
    expect(t, m.eq(mat.specular, 0.9));
    expect(t, m.eq(mat.shininess, 200));
}

package tests_graphics

import "core:testing"

import g "raytracer:graphics"
import m "raytracer:math"

import r "../runner"

material_suite := r.Test_Suite {
    name = "Mat/",
    tests = {
        r.test("Material_Constructor_Default", Material_Constructor_Default)
    },

}

@test
Material_Constructor_Default :: proc(t: ^testing.T) {

    mat := g.material();

    r.expect(t, m.eq(mat.color, g.color(1, 1, 1)));
    r.expect(t, m.eq(mat.ambient, 0.1));
    r.expect(t, m.eq(mat.diffuse, 0.9));
    r.expect(t, m.eq(mat.specular, 0.9));
    r.expect(t, m.eq(mat.shininess, 200));
}

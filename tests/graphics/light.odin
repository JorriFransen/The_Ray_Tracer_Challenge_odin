package tests_graphics

import "core:testing"
import "core:math"

import g "raytracer:graphics"
import m "raytracer:math"

import r "../runner"

light_suite := r.Test_Suite {
    name = "Light/",
    tests = {
        r.test("Point_Light_Constructor", Point_Light_Constructor),
        r.test("L_Light_Eye_Surface", L_Light_Eye_Surface),
        r.test("L_Light_Eye45_Surface", L_Light_Eye45_Surface),
        r.test("L_Light45_Eye_Surface", L_Light45_Eye_Surface),
        r.test("L_Light45_Eyen45_Surface", L_Light45_Eyen45_Surface),
        r.test("L_Eye_Surface_Light", L_Eye_Surface_Light),
    },

}

@test
Point_Light_Constructor :: proc(t: ^testing.T) {

    intensity := g.color(1, 1, 1);
    position := m.point(0, 0, 0);

    light := g.point_light(position, intensity);

    r.expect(t, m.eq(light.position, position));
    r.expect(t, m.eq(light.intensity, intensity));
}

@test
L_Light_Eye_Surface :: proc(t: ^testing.T) {

    mat := g.material();
    position := m.point(0, 0, 0);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := g.point_light(m.point(0, 0, -10), g.color(1, 1, 1));

    result := g.lighting(mat, light, position, eyev, normalv);

    r.expect(t, m.eq(result, g.color(1.9, 1.9, 1.9)));
}

@test
L_Light_Eye45_Surface :: proc(t: ^testing.T) {

    mat := g.material();
    position := m.point(0, 0, 0);

    sqrt2_over_2 := math.sqrt(m.real(2)) / 2;
    eyev := m.vector(0, sqrt2_over_2, -sqrt2_over_2);
    normalv := m.vector(0, 0, -1);
    light := g.point_light(m.point(0, 0, -10), g.color(1, 1, 1));

    result := g.lighting(mat, light, position, eyev, normalv);

    r.expect(t, m.eq(result, g.color(1.0, 1.0, 1.0)));
}

@test
L_Light45_Eye_Surface :: proc(t: ^testing.T) {

    mat := g.material();
    position := m.point(0, 0, 0);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := g.point_light(m.point(0, 10, -10), g.color(1, 1, 1));

    result := g.lighting(mat, light, position, eyev, normalv);

    r.expect(t, m.eq(result, g.color(0.7364, 0.7364, 0.7364)));
}

@test
L_Light45_Eyen45_Surface :: proc(t: ^testing.T) {

    mat := g.material();
    position := m.point(0, 0, 0);

    sqrt2_over_2 := math.sqrt(m.real(2)) / 2;
    eyev := m.vector(0, -sqrt2_over_2, -sqrt2_over_2);
    normalv := m.vector(0, 0, -1);
    light := g.point_light(m.point(0, 10, -10), g.color(1, 1, 1));

    result := g.lighting(mat, light, position, eyev, normalv);

    r.expect(t, m.eq(result, g.color(1.63639, 1.63639, 1.63639)));
}

@test
L_Eye_Surface_Light :: proc(t: ^testing.T) {

    mat := g.material();
    position := m.point(0, 0, 0);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := g.point_light(m.point(0, 0, 10), g.color(1, 1, 1));

    result := g.lighting(mat, light, position, eyev, normalv);

    r.expect(t, m.eq(result, g.color(0.1, 0.1, 0.1)));
}

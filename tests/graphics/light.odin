package tests_graphics

import "core:math"

import rt "raytracer:."
import m "raytracer:math"

import r "raytracer:test_runner"

light_suite := r.Test_Suite {
    name = "Light/",
    tests = {
        r.test("Point_Light_Constructor", Point_Light_Constructor),
        r.test("L_Light_Eye_Surface", L_Light_Eye_Surface),
        r.test("L_Light_Eye45_Surface", L_Light_Eye45_Surface),
        r.test("L_Light45_Eye_Surface", L_Light45_Eye_Surface),
        r.test("L_Light45_Eyen45_Surface", L_Light45_Eyen45_Surface),
        r.test("L_Eye_Surface_Light", L_Eye_Surface_Light),
        r.test("L_Surface_Shadow", L_Surface_Shadow),
    },

}

@test
Point_Light_Constructor :: proc(t: ^r.Test_Context) {

    intensity := rt.color(1, 1, 1);
    position := m.point(0, 0, 0);

    light := rt.point_light(position, intensity);

    expect(t, eq(light.position, position));
    expect(t, eq(light.intensity, intensity));
}

@test
L_Light_Eye_Surface :: proc(t: ^r.Test_Context) {

    mat := rt.material();
    position := m.point(0, 0, 0);

    obj := rt.sphere(mat);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 0, -10), rt.color(1, 1, 1));

    result := rt.lighting(&obj, light, position, eyev, normalv);

    expect(t, eq(result, rt.color(1.9, 1.9, 1.9)));
}

@test
L_Light_Eye45_Surface :: proc(t: ^r.Test_Context) {

    mat := rt.material();
    position := m.point(0, 0, 0);

    obj := rt.sphere(mat);

    sqrt2_over_2 := math.sqrt(m.real(2)) / 2;
    eyev := m.vector(0, sqrt2_over_2, -sqrt2_over_2);
    normalv := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 0, -10), rt.color(1, 1, 1));

    result := rt.lighting(&obj, light, position, eyev, normalv);

    expect(t, eq(result, rt.color(1.0, 1.0, 1.0)));
}

@test
L_Light45_Eye_Surface :: proc(t: ^r.Test_Context) {

    mat := rt.material();
    position := m.point(0, 0, 0);

    obj := rt.sphere( mat);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 10, -10), rt.color(1, 1, 1));

    result := rt.lighting(&obj, light, position, eyev, normalv);

    expect(t, eq(result, rt.color(0.7364, 0.7364, 0.7364)));
}

@test
L_Light45_Eyen45_Surface :: proc(t: ^r.Test_Context) {

    mat := rt.material();
    position := m.point(0, 0, 0);

    obj := rt.sphere(mat);

    sqrt2_over_2 := math.sqrt(m.real(2)) / 2;
    eyev := m.vector(0, -sqrt2_over_2, -sqrt2_over_2);
    normalv := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 10, -10), rt.color(1, 1, 1));

    result := rt.lighting(&obj, light, position, eyev, normalv);

    expect(t, eq(result, rt.color(1.63639, 1.63639, 1.63639)));
}

@test
L_Eye_Surface_Light :: proc(t: ^r.Test_Context) {

    mat := rt.material();
    position := m.point(0, 0, 0);

    obj := rt.sphere(mat);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 0, 10), rt.color(1, 1, 1));

    result := rt.lighting(&obj, light, position, eyev, normalv);

    expect(t, eq(result, rt.color(0.1, 0.1, 0.1)));
}

@test
L_Surface_Shadow :: proc(t: ^r.Test_Context) {

    mat := rt.material();
    position := m.point(0, 0, 0);

    obj := rt.sphere( mat);

    eyev := m.vector(0, 0, -1);
    normalv := m.vector(0, 0, -1);
    light := rt.point_light(m.point(0, 0, -10), rt.color(1, 1, 1));
    in_shadow := true;

    result := rt.lighting(&obj, light, position, eyev, normalv, in_shadow);

    expect(t, eq(result, rt.color(0.1, 0.1, 0.1)));

}

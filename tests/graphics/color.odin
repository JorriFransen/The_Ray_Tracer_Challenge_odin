package tests_graphics

import rt "raytracer:."
import rm "raytracer:math"
import r "raytracer:test_runner"

color_suite := r.Test_Suite {
    name = "Col/",
    tests = {
        r.test("Co_Constructor", Co_Constructor),
        r.test("Co_Layout_Matches_Tuple", Co_Layout_Matches_Tuple),
        r.test("Co_Add", Co_Add),
        r.test("Co_Sub", Co_Sub),
        r.test("Co_Mul_Scalar", Co_Mul_Scalar),
        r.test("Co_Mul", Co_Mul),
    },
}

@test
Co_Constructor :: proc(t: ^r.Test_Context) {

    c := rt.color(-0.5, 0.4, 1.7);

    expected_r :: -0.5;
    expected_g :: 0.4;
    expected_b :: 1.7;

    expect(t, c.r == expected_r);
    expect(t, c.g == expected_g);
    expect(t, c.b == expected_b);

}

@test
Co_Layout_Matches_Tuple :: proc(t: ^r.Test_Context) {

    c := rt.color(-0.5, 0.4, 1.7);

    expected := rm.tuple(-0.5, 0.4, 1.7, 0.0);

    expect(t, transmute(rm.Tuple)c == expected);
    expect(t, c == transmute(rt.Color)expected);
    expect(t, rm.tuple(c.r, c.g, c.b, 0.0) == expected);
}

@test
Co_Add :: proc(t: ^r.Test_Context) {

    c1 := rt.color(0.9, 0.6, 0.75);
    c2 := rt.color(0.7, 0.1, 0.25);

    expected := rt.color(1.6, 0.7, 1.0);
    result : rt.Color = rt.add(c1, c2);

    expect(t, eq(result, expected));
}

@test
Co_Sub :: proc(t: ^r.Test_Context) {

    c1 := rt.color(0.9, 0.6, 0.75);
    c2 := rt.color(0.7, 0.1, 0.25);

    expected := rt.color(0.2, 0.5, 0.5);
    result := rt.sub(c1, c2);

    expect(t, eq(result, expected));
}

@test
Co_Mul_Scalar :: proc(t: ^r.Test_Context) {

    c := rt.color(0.2, 0.3, 0.4);

    expected := rt.color(0.4, 0.6, 0.8);
    result := rt.mul(c, 2);

    expect(t, eq(result, expected));
}

@test
Co_Mul :: proc(t: ^r.Test_Context) {

    c1 := rt.color(1.0, 0.2, 0.4);
    c2 := rt.color(0.9, 1, 0.1);

    expected := rt.color(0.9, 0.2, 0.04);
    result := rt.mul(c1, c2);

    expect(t, eq(result, expected));
}

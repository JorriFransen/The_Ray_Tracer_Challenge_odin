package tests

import "core:testing"
import g "raytracer:graphics"
import rm "raytracer:math"

import r "runner"

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
Co_Constructor :: proc(t: ^testing.T) {

    c := g.color(-0.5, 0.4, 1.7);

    expected_r :: -0.5;
    expected_g :: 0.4;
    expected_b :: 1.7;

    r.expect(t, c.r == expected_r);
    r.expect(t, c.g == expected_g);
    r.expect(t, c.b == expected_b);

}

@test
Co_Layout_Matches_Tuple :: proc(t: ^testing.T) {

    c := g.color(-0.5, 0.4, 1.7);

    expected := rm.tuple(-0.5, 0.4, 1.7, 0.0);

    r.expect(t, transmute(rm.Tuple)c == expected);
    r.expect(t, c == transmute(g.Color)expected);
    r.expect(t, rm.tuple(c.r, c.g, c.b, 0.0) == expected);
}

@test
Co_Add :: proc(t: ^testing.T) {

    c1 := g.color(0.9, 0.6, 0.75);
    c2 := g.color(0.7, 0.1, 0.25);

    expected := g.color(1.6, 0.7, 1.0);
    result := g.add(c1, c2);

    r.expect(t, g.eq(result, expected));
}

@test
Co_Sub :: proc(t: ^testing.T) {

    c1 := g.color(0.9, 0.6, 0.75);
    c2 := g.color(0.7, 0.1, 0.25);

    expected := g.color(0.2, 0.5, 0.5);
    result := g.sub(c1, c2);

    r.expect(t, g.eq(result, expected));
}

@test
Co_Mul_Scalar :: proc(t: ^testing.T) {

    c := g.color(0.2, 0.3, 0.4);

    expected := g.color(0.4, 0.6, 0.8);
    result := g.mul(c, 2);

    r.expect(t, g.eq(result, expected));
}

@test
Co_Mul :: proc(t: ^testing.T) {

    c1 := g.color(1.0, 0.2, 0.4);
    c2 := g.color(0.9, 1, 0.1);

    expected := g.color(0.9, 0.2, 0.04);
    result := g.mul(c1, c2);

    r.expect(t, g.eq(result, expected));
}

package tests;

import "core:testing"

import rm "raytracer:math"

transform_suite := Test_Suite {
    name = "Tfm/",
    tests = {
        test("P_Mul_Translation", P_Mul_Translation),
        test("P_Mul_Inv_Translation", P_Mul_Inv_Translation),
        test("V_Mul_Translation", V_Mul_Translation),
    },
};

@test
P_Mul_Translation :: proc(t: ^testing.T) {

    transform := rm.translation(5, -3, 2);
    p := rm.point(-3, 4, 5);

    expected := rm.point(2, 1, 7);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, result1 == expected);
    expect(t, result2 == expected);
}

@test
P_Mul_Inv_Translation :: proc(t: ^testing.T) {

    transform := rm.translation(5, -3, 2);
    inv := rm.matrix_inverse(transform);
    p := rm.point(-3, 4, 5);

    expected := rm.point(-8, 7, 3);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, result1 == expected);
    expect(t, result2 == expected);
}

@test
V_Mul_Translation :: proc(t: ^testing.T) {

    transform := rm.translation(5, -3, 2);
    v := rm.vector(-3, 4, 5);

    result1 := rm.mul(transform, v);
    result2 := transform * v;

    expect(t, result1 == v);
    expect(t, result2 == v);
}

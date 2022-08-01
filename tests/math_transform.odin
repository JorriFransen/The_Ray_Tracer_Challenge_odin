package tests;

import "core:fmt"
import "core:testing"

import rm "raytracer:math"

transform_suite := Test_Suite {
    name = "Tfm/",
    tests = {
        test("P_Mul_Translation", P_Mul_Translation),
        test("P_Mul_Inv_Translation", P_Mul_Inv_Translation),
        test("V_Mul_Translation", V_Mul_Translation),
        test("P_Mul_Scale", P_Mul_Scale),
        test("V_Mul_Scale", V_Mul_Scale),
        test("V_Mul_Inv_Scale", V_Mul_Inv_Scale),
        test("Reflection_Is_Neg_Scale", Reflection_Is_Neg_Scale),
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

@test
P_Mul_Scale :: proc(t: ^testing.T) {

    transform := rm.scaling(2, 3, 4);
    p := rm.point(-4, 6, 8);

    expected := rm.point(-8, 18, 32);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, result1 == expected);
    expect(t, result2 == expected);
}

@test
V_Mul_Scale :: proc(t: ^testing.T) {

    transform := rm.scaling(2, 3, 4);
    v := rm.vector(-4, 6, 8);

    expected := rm.vector(-8, 18, 32);

    result1 := rm.mul(transform, v);
    result2 := transform * v;

    expect(t, result1 == expected);
    expect(t, result2 == expected);
}

@test
V_Mul_Inv_Scale :: proc(t: ^testing.T) {

    transform := rm.scaling(2, 3, 4);
    inv := rm.matrix_inverse(transform);
    v := rm.vector(-4, 6, 8);

    expected := rm.vector(-2, 2, 2);

    result1 := rm.mul(inv, v);
    result2 := inv * v;

    expect(t, result1 == expected);
    expect(t, result2 == expected);
}

@test
Reflection_Is_Neg_Scale :: proc(t: ^testing.T) {

    transform := rm.scaling(-1, 1, 1);
    p := rm.point(2, 3, 4);

    expected := rm.point(-2, 3, 4);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, result1 == expected);
    expect(t, result2 == expected);
}

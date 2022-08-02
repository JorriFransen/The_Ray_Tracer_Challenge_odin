package tests;

import "core:fmt"
import "core:testing"
import "core:math"

import rm "raytracer:math"

PI :: math.PI;
sqrt :: math.sqrt;

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
        test("Rotate_Around_X", Rotate_Around_X),
        test("Rotate_Around_X_Inv", Rotate_Around_X_Inv),
        test("Rotate_Around_Y", Rotate_Around_Y),
        test("Rotate_Around_Y_Inv", Rotate_Around_Y_Inv),
        test("Rotate_Around_Z", Rotate_Around_Z),
        test("Rotate_Around_Z_Inv", Rotate_Around_Z_Inv),
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

@test
Rotate_Around_X :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_x(math.PI / 4);
    full_quarter := rm.rotation_x(math.PI / 2);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected1 := rm.point(0, sqrt2_d2, sqrt2_d2);
    expected2 := rm.point(0, 0, 1);

    half_result_1 := rm.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := rm.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    expect(t, rm.eq(half_result_1, expected1));
    expect(t, rm.eq(half_result_2, expected1));

    expect(t, rm.eq(full_result_1, expected2));
    expect(t, rm.eq(full_result_2, expected2));
}

@test
Rotate_Around_X_Inv :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_x(math.PI / 4);
    inv := rm.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected := rm.point(0, sqrt2_d2, -sqrt2_d2);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
}

@test
Rotate_Around_Y :: proc(t: ^testing.T) {

    p := rm.point(0, 0, 1);
    half_quarter := rm.rotation_y(math.PI / 4);
    full_quarter := rm.rotation_y(math.PI / 2);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected1 := rm.point(sqrt2_d2, 0, sqrt2_d2);
    expected2 := rm.point(1, 0, 0);

    half_result_1 := rm.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := rm.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    expect(t, rm.eq(half_result_1, expected1));
    expect(t, rm.eq(half_result_2, expected1));

    expect(t, rm.eq(full_result_1, expected2));
    expect(t, rm.eq(full_result_2, expected2));
}

@test
Rotate_Around_Y_Inv :: proc(t: ^testing.T) {

    p := rm.point(0, 0, 1);
    half_quarter := rm.rotation_y(math.PI / 4);
    inv := rm.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected := rm.point(-sqrt2_d2, 0, sqrt2_d2);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
}

@test
Rotate_Around_Z :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_z(math.PI / 4);
    full_quarter := rm.rotation_z(math.PI / 2);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected1 := rm.point(-sqrt2_d2, sqrt2_d2, 0);
    expected2 := rm.point(-1, 0, 0);

    half_result_1 := rm.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := rm.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    expect(t, rm.eq(half_result_1, expected1));
    expect(t, rm.eq(half_result_2, expected1));

    expect(t, rm.eq(full_result_1, expected2));
    expect(t, rm.eq(full_result_2, expected2));
}

@test
Rotate_Around_Z_Inv :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_z(math.PI / 4);
    inv := rm.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected := rm.point(sqrt2_d2, sqrt2_d2, 0);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
}

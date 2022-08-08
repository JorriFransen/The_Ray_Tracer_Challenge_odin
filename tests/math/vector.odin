package tests_math

import "core:intrinsics"
import "core:testing"
import "core:math"

import cm "core:math"
import rm "raytracer:math"

import r "raytracer:test_runner"

vec_suite := r.Test_Suite {
    name = "Vec/",
    tests = {
        r.test("T_Is_Point", T_Is_Point),
        r.test("T_Is_Vector", T_Is_Vector),
        r.test("P_Constructor", P_Constructor),
        r.test("V_Constructor", V_Constructor),
        r.test("T_Add", T_Add),
        r.test("P_Add_Vector", P_Add_Vector),
        r.test("V_Add_Point", V_Add_Point),
        r.test("V_Add", V_Add),
        r.test("T_Sub", T_Sub),
        r.test("P_Sub", P_Sub),
        r.test("P_Sub_Vector", P_Sub_Vector),
        r.test("V_Sub", V_Sub),
        r.test("V_Sub_From_Zero", V_Sub_From_Zero),
        r.test("T_Negate", T_Negate),
        r.test("V_Negate", V_Negate),
        r.test("T_Mul_Scalar", T_Mul_Scalar),
        r.test("T_Mul_Fraction", T_Mul_Fraction),
        r.test("T_Div_Scalar", T_Div_Scalar),
        r.test("V_Magnitude_X1", V_Magnitude_X1),
        r.test("V_Magnitude_Y1", V_Magnitude_Y1),
        r.test("V_Magnitude_Z1", V_Magnitude_Z1),
        r.test("V_Magnitude_X1_Y2_Z3", V_Magnitude_X1_Y2_Z3),
        r.test("V_Magnitude_X1_Y2_Z3_Neg", V_Magnitude_X1_Y2_Z3_Neg),
        r.test("V_Normalize_X4", V_Normalize_X4),
        r.test("V_Normalize_X1_Y2_Z3", V_Normalize_X1_Y2_Z3),
        r.test("V_Dot", V_Dot),
        r.test("V_Cross", V_Cross),
        r.test("V_Reflect", V_Reflect),
        r.test("V_Reflect_Slanted_Surface", V_Reflect_Slanted_Surface),
    },
}

@test
T_Is_Point :: proc(t: ^r.Test_Context) {

    a := rm.tuple(4.3, -4.2, 3.1, 1.0);

    r.expect(t, a.x == 4.3);
    r.expect(t, a.y == -4.2);
    r.expect(t, a.z == 3.1);
    r.expect(t, a.w == 1.0);

    r.expect(t, rm.is_point(a));
    r.expect(t, !rm.is_vector(a));
}

@test
T_Is_Vector :: proc(t: ^r.Test_Context) {

    a := rm.tuple(4.3, -4.2, 3.1, 0.0);

    r.expect(t, a.x == 4.3);
    r.expect(t, a.y == -4.2);
    r.expect(t, a.z == 3.1);
    r.expect(t, a.w == 0.0);

    r.expect(t, rm.is_vector(a));
    r.expect(t, !rm.is_point(a));
}

@test
P_Constructor :: proc(t: ^r.Test_Context) {

    p := rm.point(4, -4, 3);

    expected := rm.tuple(4, -4, 3, 1);

    r.expect(t, rm.is_point(p));
    r.expect(t, transmute(rm.Tuple)p == expected);
    r.expect(t, p == transmute(rm.Point)expected);
    r.expect(t, rm.eq(p, expected));
}

@test
V_Constructor :: proc(t: ^r.Test_Context) {

    v := rm.vector(4, -4, 3);

    expected := rm.tuple(4, -4, 3, 0);

    r.expect(t, rm.is_vector(v));
    r.expect(t, transmute(rm.Tuple)v == expected);
    r.expect(t, v == transmute(rm.Vector)expected);
    r.expect(t, rm.eq(v, expected));
}

@test
T_Add :: proc(t: ^r.Test_Context) {

    a1 := rm.tuple(3, -2, 5, 1);
    a2 := rm.tuple(-2, 3, 1, 0);

    expected := rm.tuple(1, 1, 6, 1);
    result1 := a1 + a2;
    result2 := rm.add(a1, a2);

    r.expect(t, result1 == expected);
    r.expect(t, rm.eq(result1, expected));
    r.expect(t, result2 == expected);
    r.expect(t, rm.eq(result2, expected));
}

@test
P_Add_Vector :: proc(t: ^r.Test_Context) {

    p := rm.point(3, -2, 5);
    v := rm.vector(-2, 3, 1);

    expected := rm.point(1, 1, 6);
    result : rm.Point = rm.add(p, v);

    r.expect(t, rm.is_point(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
V_Add_Point :: proc(t: ^r.Test_Context) {

    v := rm.vector(3, -2, 5);
    p := rm.point(-2, 3, 1);

    expected := rm.point(1, 1, 6);
    result : rm.Point = rm.add(v, p);

    r.expect(t, rm.is_point(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
V_Add :: proc(t: ^r.Test_Context) {

    v1 := rm.vector(3, -2, 5);
    v2 := rm.vector(-2, 3, 1);

    expected := rm.vector(1, 1, 6);
    result : rm.Vector = rm.add(v1, v2);

    r.expect(t, rm.is_vector(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
T_Sub :: proc(t: ^r.Test_Context) {

    a := rm.tuple(3, 2, 1, 1);
    b := rm.tuple(5, 6, 7, 1);

    expected := rm.tuple(-2, -4, -6, 0);
    result := rm.sub(a, b);

    r.expect(t, rm.is_vector(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
P_Sub :: proc(t: ^r.Test_Context) {

    a := rm.point(3, 2, 1);
    b := rm.point(5, 6, 7);

    expected := rm.vector(-2, -4, -6);
    result : rm.Vector = rm.sub(a, b);

    r.expect(t, rm.is_vector(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
P_Sub_Vector :: proc(t: ^r.Test_Context) {

    p := rm.point(3, 2, 1);
    v := rm.vector(5, 6, 7);

    expected := rm.point(-2, -4, -6);
    result : rm.Point = rm.sub(p, v);

    r.expect(t, rm.is_point(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
V_Sub :: proc(t: ^r.Test_Context) {

    v1 := rm.vector(3, 2, 1);
    v2 := rm.vector(5, 6, 7);

    expected := rm.vector(-2, -4, -6);
    result : rm.Vector = rm.sub(v1, v2);

    r.expect(t, rm.is_vector(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}


@test
V_Sub_From_Zero :: proc(t: ^r.Test_Context) {

    zero := rm.vector(0, 0, 0);
    v := rm.vector(1, -2, 3);

    expected := rm.vector(-1, 2, -3);
    result : rm.Vector = rm.sub(zero, v);

    r.expect(t, rm.is_vector(result));
    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
T_Negate :: proc(t: ^r.Test_Context) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(-1, 2, -3, 4);
    result := rm.negate(a);

    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
V_Negate :: proc(t: ^r.Test_Context) {

    v := rm.vector(1, -2, 3);

    expected := rm.vector(-1, 2, -3);
    result : rm.Vector = rm.negate(v);

    r.expect(t, rm.is_vector(result));
    r.expect(t, rm.eq(result, expected));
}

@test
T_Mul_Scalar :: proc(t: ^r.Test_Context) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(3.5, -7, 10.5, -14);
    result := rm.mul(a, 3.5);

    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
T_Mul_Fraction :: proc(t: ^r.Test_Context) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(0.5, -1, 1.5, -2);
    result := rm.mul(a, 0.5);

    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
T_Div_Scalar :: proc(t: ^r.Test_Context) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(0.5, -1, 1.5, -2);
    result := rm.div(a, 2);

    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
V_Magnitude_X1 :: proc(t: ^r.Test_Context) {

    v := rm.vector(1, 0, 0);

    expected :: 1.0;
    result := rm.magnitude(v);

    r.expect(t, result == expected);
}

@test
V_Magnitude_Y1 :: proc(t: ^r.Test_Context) {

    v := rm.vector(0, 1, 0);

    expected :: 1.0;
    result := rm.magnitude(v);

    r.expect(t, result == expected);
}

@test
V_Magnitude_Z1 :: proc(t: ^r.Test_Context) {

    v := rm.vector(0, 0, 1);

    expected :: 1.0;
    result := rm.magnitude(v);

    r.expect(t, result == expected);
}

@test
V_Magnitude_X1_Y2_Z3 :: proc(t: ^r.Test_Context) {

    v := rm.vector(1, 2, 3);

    expected := cm.sqrt(intrinsics.type_field_type(rm.Vector, "x")(14));
    result := rm.magnitude(v);

    r.expect(t, result == expected);
}

@test
V_Magnitude_X1_Y2_Z3_Neg :: proc(t: ^r.Test_Context) {

    v := rm.vector(-1, -2, -3);

    expected := cm.sqrt(intrinsics.type_field_type(rm.Vector, "x")(14));
    result := rm.magnitude(v);

    r.expect(t, result == expected);
}

@test
V_Normalize_X4 :: proc(t: ^r.Test_Context) {

    v := rm.vector(4, 0, 0);

    expected := rm.vector(1, 0, 0);
    result := rm.normalize(v);

    r.expect(t, result == expected);
    r.expect(t, rm.eq(result, expected));
}

@test
V_Normalize_X1_Y2_Z3 :: proc(t: ^r.Test_Context) {

    v := rm.vector(1, 2, 3);

    // 1*1 + 2*2 + 3*3 = 14
    /*expected := rm.vector(1 / crm.sqrt(f32(14)), 2 / crm.sqrt(f32(14)), 3 / crm.sqrt(f32(14)));*/
    expected := rm.vector(0.267271, 0.53452, 0.80178);
    result := rm.normalize(v);

    /*expect(t, result == expected);*/
    r.expect(t, rm.eq(result, expected));
}

@test
V_Dot :: proc(t: ^r.Test_Context) {

    a := rm.vector(1, 2, 3);
    b := rm.vector(2, 3, 4);

    expected :: 20.0;
    result := rm.dot(a, b);

    r.expect(t, result == expected);
}

@test
V_Cross :: proc(t: ^r.Test_Context) {

    a := rm.vector(1, 2, 3);
    b := rm.vector(2, 3, 4);

    expected_ab := rm.vector(-1, 2, -1);
    expected_ba := rm.vector(1, -2, 1);

    result_ab := rm.cross(a, b);
    result_ba := rm.cross(b, a);

    r.expect(t, rm.is_vector(result_ab));
    r.expect(t, rm.is_vector(result_ba));

    r.expect(t, result_ab == expected_ab);
    r.expect(t, rm.eq(result_ab, expected_ab));
    r.expect(t, result_ba == expected_ba);
    r.expect(t, rm.eq(result_ba, expected_ba));
}

@test
V_Reflect :: proc(t: ^r.Test_Context) {

    v := rm.vector(1, -1, 0);
    n := rm.vector(0, 1, 0);

    ref := rm.reflect(v, n);

    r.expect(t, rm.eq(ref, rm.vector(1, 1, 0)));
}

@test
V_Reflect_Slanted_Surface :: proc(t: ^r.Test_Context) {

    v := rm.vector(0, -1, 0);
    sqrt2_over_2 := math.sqrt(rm.real(2))/2;
    n := rm.vector(sqrt2_over_2, sqrt2_over_2, 0);

    ref := rm.reflect(v, n);

    r.expect(t, rm.eq(ref, rm.vector(1, 0, 0)));
}

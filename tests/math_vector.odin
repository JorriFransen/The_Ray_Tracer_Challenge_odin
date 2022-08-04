package tests

import "core:intrinsics"
import "core:testing"
import "core:math"

import cm "core:math"
import rm "raytracer:math"

vec_suite := Test_Suite {
    name = "Vec/",
    tests = {
        test("T_Is_Point", T_Is_Point),
        test("T_Is_Vector", T_Is_Vector),
        test("P_Constructor", P_Constructor),
        test("V_Constructor", V_Constructor),
        test("T_Add", T_Add),
        test("P_Add_Vector", P_Add_Vector),
        test("V_Add_Point", V_Add_Point),
        test("V_Add", V_Add),
        test("T_Sub", T_Sub),
        test("P_Sub", P_Sub),
        test("P_Sub_Vector", P_Sub_Vector),
        test("V_Sub", V_Sub),
        test("V_Sub_From_Zero", V_Sub_From_Zero),
        test("T_Negate", T_Negate),
        test("V_Negate", V_Negate),
        test("T_Mul_Scalar", T_Mul_Scalar),
        test("T_Mul_Fraction", T_Mul_Fraction),
        test("T_Div_Scalar", T_Div_Scalar),
        test("V_Magnitude_X1", V_Magnitude_X1),
        test("V_Magnitude_Y1", V_Magnitude_Y1),
        test("V_Magnitude_Z1", V_Magnitude_Z1),
        test("V_Magnitude_X1_Y2_Z3", V_Magnitude_X1_Y2_Z3),
        test("V_Magnitude_X1_Y2_Z3_Neg", V_Magnitude_X1_Y2_Z3_Neg),
        test("V_Normalize_X4", V_Normalize_X4),
        test("V_Normalize_X1_Y2_Z3", V_Normalize_X1_Y2_Z3),
        test("V_Dot", V_Dot),
        test("V_Cross", V_Cross),
        test("V_Reflect", V_Reflect),
        test("V_Reflect_Slanted_Surface", V_Reflect_Slanted_Surface),
    },
}

@test
T_Is_Point :: proc(t: ^testing.T) {

    a := rm.tuple(4.3, -4.2, 3.1, 1.0);

    expect(t, a.x == 4.3);
    expect(t, a.y == -4.2);
    expect(t, a.z == 3.1);
    expect(t, a.w == 1.0);

    expect(t, rm.is_point(a));
    expect(t, !rm.is_vector(a));
}

@test
T_Is_Vector :: proc(t: ^testing.T) {

    a := rm.tuple(4.3, -4.2, 3.1, 0.0);

    expect(t, a.x == 4.3);
    expect(t, a.y == -4.2);
    expect(t, a.z == 3.1);
    expect(t, a.w == 0.0);

    expect(t, rm.is_vector(a));
    expect(t, !rm.is_point(a));
}

@test
P_Constructor :: proc(t: ^testing.T) {

    p := rm.point(4, -4, 3);

    expected := rm.tuple(4, -4, 3, 1);

    expect(t, rm.is_point(p));
    expect(t, transmute(rm.Tuple)p == expected);
    expect(t, p == transmute(rm.Point)expected);
    expect(t, rm.eq(p, expected));
}

@test
V_Constructor :: proc(t: ^testing.T) {

    v := rm.vector(4, -4, 3);

    expected := rm.tuple(4, -4, 3, 0);

    expect(t, rm.is_vector(v));
    expect(t, transmute(rm.Tuple)v == expected);
    expect(t, v == transmute(rm.Vector)expected);
    expect(t, rm.eq(v, expected));
}

@test
T_Add :: proc(t: ^testing.T) {

    a1 := rm.tuple(3, -2, 5, 1);
    a2 := rm.tuple(-2, 3, 1, 0);

    expected := rm.tuple(1, 1, 6, 1);
    result1 := a1 + a2;
    result2 := rm.add(a1, a2);

    expect(t, result1 == expected);
    expect(t, rm.eq(result1, expected));
    expect(t, result2 == expected);
    expect(t, rm.eq(result2, expected));
}

@test
P_Add_Vector :: proc(t: ^testing.T) {

    p := rm.point(3, -2, 5);
    v := rm.vector(-2, 3, 1);

    expected := rm.point(1, 1, 6);
    result : rm.Point = rm.add(p, v);

    expect(t, rm.is_point(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
V_Add_Point :: proc(t: ^testing.T) {

    v := rm.vector(3, -2, 5);
    p := rm.point(-2, 3, 1);

    expected := rm.point(1, 1, 6);
    result : rm.Point = rm.add(v, p);

    expect(t, rm.is_point(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
V_Add :: proc(t: ^testing.T) {

    v1 := rm.vector(3, -2, 5);
    v2 := rm.vector(-2, 3, 1);

    expected := rm.vector(1, 1, 6);
    result : rm.Vector = rm.add(v1, v2);

    expect(t, rm.is_vector(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
T_Sub :: proc(t: ^testing.T) {

    a := rm.tuple(3, 2, 1, 1);
    b := rm.tuple(5, 6, 7, 1);

    expected := rm.tuple(-2, -4, -6, 0);
    result := rm.sub(a, b);

    expect(t, rm.is_vector(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
P_Sub :: proc(t: ^testing.T) {

    a := rm.point(3, 2, 1);
    b := rm.point(5, 6, 7);

    expected := rm.vector(-2, -4, -6);
    result : rm.Vector = rm.sub(a, b);

    expect(t, rm.is_vector(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
P_Sub_Vector :: proc(t: ^testing.T) {

    p := rm.point(3, 2, 1);
    v := rm.vector(5, 6, 7);

    expected := rm.point(-2, -4, -6);
    result : rm.Point = rm.sub(p, v);

    expect(t, rm.is_point(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
V_Sub :: proc(t: ^testing.T) {

    v1 := rm.vector(3, 2, 1);
    v2 := rm.vector(5, 6, 7);

    expected := rm.vector(-2, -4, -6);
    result : rm.Vector = rm.sub(v1, v2);

    expect(t, rm.is_vector(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}


@test
V_Sub_From_Zero :: proc(t: ^testing.T) {

    zero := rm.vector(0, 0, 0);
    v := rm.vector(1, -2, 3);

    expected := rm.vector(-1, 2, -3);
    result : rm.Vector = rm.sub(zero, v);

    expect(t, rm.is_vector(result));
    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
T_Negate :: proc(t: ^testing.T) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(-1, 2, -3, 4);
    result := rm.negate(a);

    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
V_Negate :: proc(t: ^testing.T) {

    v := rm.vector(1, -2, 3);

    expected := rm.vector(-1, 2, -3);
    result : rm.Vector = rm.negate(v);

    expect(t, rm.is_vector(result));
    expect(t, rm.eq(result, expected));
}

@test
T_Mul_Scalar :: proc(t: ^testing.T) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(3.5, -7, 10.5, -14);
    result := rm.mul(a, 3.5);

    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
T_Mul_Fraction :: proc(t: ^testing.T) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(0.5, -1, 1.5, -2);
    result := rm.mul(a, 0.5);

    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
T_Div_Scalar :: proc(t: ^testing.T) {

    a := rm.tuple(1, -2, 3, -4);

    expected := rm.tuple(0.5, -1, 1.5, -2);
    result := rm.div(a, 2);

    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
V_Magnitude_X1 :: proc(t: ^testing.T) {

    v := rm.vector(1, 0, 0);

    expected :: 1.0;
    result := rm.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_Y1 :: proc(t: ^testing.T) {

    v := rm.vector(0, 1, 0);

    expected :: 1.0;
    result := rm.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_Z1 :: proc(t: ^testing.T) {

    v := rm.vector(0, 0, 1);

    expected :: 1.0;
    result := rm.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_X1_Y2_Z3 :: proc(t: ^testing.T) {

    v := rm.vector(1, 2, 3);

    expected := cm.sqrt(intrinsics.type_field_type(rm.Vector, "x")(14));
    result := rm.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_X1_Y2_Z3_Neg :: proc(t: ^testing.T) {

    v := rm.vector(-1, -2, -3);

    expected := cm.sqrt(intrinsics.type_field_type(rm.Vector, "x")(14));
    result := rm.magnitude(v);

    expect(t, result == expected);
}

@test
V_Normalize_X4 :: proc(t: ^testing.T) {

    v := rm.vector(4, 0, 0);

    expected := rm.vector(1, 0, 0);
    result := rm.normalize(v);

    expect(t, result == expected);
    expect(t, rm.eq(result, expected));
}

@test
V_Normalize_X1_Y2_Z3 :: proc(t: ^testing.T) {

    v := rm.vector(1, 2, 3);

    // 1*1 + 2*2 + 3*3 = 14
    /*expected := rm.vector(1 / crm.sqrt(f32(14)), 2 / crm.sqrt(f32(14)), 3 / crm.sqrt(f32(14)));*/
    expected := rm.vector(0.267271, 0.53452, 0.80178);
    result := rm.normalize(v);

    /*expect(t, result == expected);*/
    expect(t, rm.eq(result, expected));
}

@test
V_Dot :: proc(t: ^testing.T) {

    a := rm.vector(1, 2, 3);
    b := rm.vector(2, 3, 4);

    expected :: 20.0;
    result := rm.dot(a, b);

    expect(t, result == expected);
}

@test
V_Cross :: proc(t: ^testing.T) {

    a := rm.vector(1, 2, 3);
    b := rm.vector(2, 3, 4);

    expected_ab := rm.vector(-1, 2, -1);
    expected_ba := rm.vector(1, -2, 1);

    result_ab := rm.cross(a, b);
    result_ba := rm.cross(b, a);

    expect(t, rm.is_vector(result_ab));
    expect(t, rm.is_vector(result_ba));

    expect(t, result_ab == expected_ab);
    expect(t, rm.eq(result_ab, expected_ab));
    expect(t, result_ba == expected_ba);
    expect(t, rm.eq(result_ba, expected_ba));
}

@test
V_Reflect :: proc(t: ^testing.T) {

    v := rm.vector(1, -1, 0);
    n := rm.vector(0, 1, 0);

    r := rm.reflect(v, n);

    expect(t, rm.eq(r, rm.vector(1, 1, 0)));
}

@test
V_Reflect_Slanted_Surface :: proc(t: ^testing.T) {

    v := rm.vector(0, -1, 0);
    sqrt2_over_2 := math.sqrt(rm.Tuple_Element_Type(2))/2;
    n := rm.vector(sqrt2_over_2, sqrt2_over_2, 0);

    r := rm.reflect(v, n);

    expect(t, rm.eq(r, rm.vector(1, 0, 0)));
}

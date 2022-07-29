package tests

import "core:fmt"
import "core:testing"
import "core:intrinsics"
import cm "core:math"

import m "../src/rtmath"

all_math_tests :: proc(t: ^testing.T) {

    Tuple_Is_Point(t);
    Tuple_Is_Vector(t);
    Point_Constructor(t);
    Vector_Constructor(t);
    Tuple_Add(t);
    Add_Point_And_Vector(t);
    Add_Vector_And_Point(t);
    Vector_Add(t);
    Tuple_Sub(t);
    Point_Sub(t);
    Point_Sub_Vector(t);
    Vector_Sub(t);
    Vector_Sub_From_Zero(t);
    Tuple_Negate(t);
    Vector_Negate(t);
    Tuple_Mul_Scalar(t);
    Tuple_Mul_Fraction(t);
    Tuple_Div_Scalar(t);
    Vector_Magnitude_X1(t);
    Vector_Magnitude_Y1(t);
    Vector_Magnitude_Z1(t);
    Vector_Magnitude_X1_Y2_Z3(t);
    Vector_Magnitude_X1_Y2_Z3_Neg(t);
    Vector_Normalize_X4(t);
    Vector_Normalize_X1_Y2_Z3(t);
    Vector_Dot(t);
    Vector_Cross(t);

    Matrix4_Construction(t);
    Matrix3_Construction(t);
    Matrix2_Construction(t);
    Matrix4_Equality(t);
    Matrix4_Inequality(t);
    Matrix3_Equality(t);
    Matrix3_Inequality(t);
    Matrix3_Equality(t);
    Matrix3_Inequality(t);
    Matrix2_Equality(t);
    Matrix2_Inequality(t);
    Matrix4_Multiply(t);
    Matrix4_Multiply_Tuple(t);
}

@test
Tuple_Is_Point :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(4.3, -4.2, 3.1, 1.0);

    expect(t, a.x == 4.3);
    expect(t, a.y == -4.2);
    expect(t, a.z == 3.1);
    expect(t, a.w == 1.0);

    expect(t, m.is_point(a));
    expect(t, !m.is_vector(a));
}

@test
Tuple_Is_Vector :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(4.3, -4.2, 3.1, 0.0);

    expect(t, a.x == 4.3);
    expect(t, a.y == -4.2);
    expect(t, a.z == 3.1);
    expect(t, a.w == 0.0);

    expect(t, m.is_vector(a));
    expect(t, !m.is_point(a));
}

@test
Point_Constructor :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    p := m.point(4, -4, 3);

    expected := m.tuple(4, -4, 3, 1);

    expect(t, m.is_point(p));
    expect(t, transmute(m.Tuple)p == expected);
    expect(t, p == transmute(m.Point)expected);
    expect(t, m.eq(p, expected));
}

@test
Vector_Constructor :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(4, -4, 3);

    expected := m.tuple(4, -4, 3, 0);

    expect(t, m.is_vector(v));
    expect(t, transmute(m.Tuple)v == expected);
    expect(t, v == transmute(m.Vector)expected);
    expect(t, m.eq(v, expected));
}

@test
Tuple_Add :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a1 := m.tuple(3, -2, 5, 1);
    a2 := m.tuple(-2, 3, 1, 0);

    expected := m.tuple(1, 1, 6, 1);
    result1 := a1 + a2;
    result2 := m.add(a1, a2);

    expect(t, result1 == expected);
    expect(t, m.eq(result1, expected));
    expect(t, result2 == expected);
    expect(t, m.eq(result2, expected));
}

@test
Add_Point_And_Vector :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    p := m.point(3, -2, 5);
    v := m.vector(-2, 3, 1);

    expected := m.point(1, 1, 6);
    result : m.Point = m.add(p, v);

    expect(t, m.is_point(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Add_Vector_And_Point :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(3, -2, 5);
    p := m.point(-2, 3, 1);

    expected := m.point(1, 1, 6);
    result : m.Point = m.add(v, p);

    expect(t, m.is_point(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Add :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v1 := m.vector(3, -2, 5);
    v2 := m.vector(-2, 3, 1);

    expected := m.vector(1, 1, 6);
    result : m.Vector = m.add(v1, v2);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Tuple_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(3, 2, 1, 1);
    b := m.tuple(5, 6, 7, 1);

    expected := m.tuple(-2, -4, -6, 0);
    result := m.sub(a, b);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Point_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.point(3, 2, 1);
    b := m.point(5, 6, 7);

    expected := m.vector(-2, -4, -6);
    result : m.Vector = m.sub(a, b);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Point_Sub_Vector :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    p := m.point(3, 2, 1);
    v := m.vector(5, 6, 7);

    expected := m.point(-2, -4, -6);
    result : m.Point = m.sub(p, v);

    expect(t, m.is_point(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v1 := m.vector(3, 2, 1);
    v2 := m.vector(5, 6, 7);

    expected := m.vector(-2, -4, -6);
    result : m.Vector = m.sub(v1, v2);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}


@test
Vector_Sub_From_Zero :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    zero := m.vector(0, 0, 0);
    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result : m.Vector = m.sub(zero, v);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Tuple_Negate :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(-1, 2, -3, 4);
    result := m.negate(a);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Negate :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result : m.Vector = m.negate(v);

    expect(t, m.is_vector(result));
    expect(t, m.eq(result, expected));
}

@test
Tuple_Mul_Scalar :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(3.5, -7, 10.5, -14);
    result := m.mul(a, 3.5);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Tuple_Mul_Fraction :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(0.5, -1, 1.5, -2);
    result := m.mul(a, 0.5);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Tuple_Div_Scalar :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(0.5, -1, 1.5, -2);
    result := m.div(a, 2);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Magnitude_X1 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, 0, 0);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_Y1 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(0, 1, 0);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_Z1 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(0, 0, 1);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1_Y2_Z3 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, 2, 3);

    expected := cm.sqrt(intrinsics.type_field_type(m.Vector, "x")(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1_Y2_Z3_Neg :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(-1, -2, -3);

    expected := cm.sqrt(intrinsics.type_field_type(m.Vector, "x")(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Normalize_X4 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(4, 0, 0);

    expected := m.vector(1, 0, 0);
    result := m.normalize(v);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Normalize_X1_Y2_Z3 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, 2, 3);

    // 1*1 + 2*2 + 3*3 = 14
    /*expected := m.vector(1 / cm.sqrt(f32(14)), 2 / cm.sqrt(f32(14)), 3 / cm.sqrt(f32(14)));*/
    expected := m.vector(0.267271, 0.53452, 0.80178);
    result := m.normalize(v);

    /*expect(t, result == expected);*/
    expect(t, m.eq(result, expected));
}

@test
Vector_Dot :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.vector(1, 2, 3);
    b := m.vector(2, 3, 4);

    expected :: 20.0;
    result := m.dot(a, b);

    expect(t, result == expected);
}

@test
Vector_Cross :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.vector(1, 2, 3);
    b := m.vector(2, 3, 4);

    expected_ab := m.vector(-1, 2, -1);
    expected_ba := m.vector(1, -2, 1);

    result_ab := m.cross(a, b);
    result_ba := m.cross(b, a);

    expect(t, m.is_vector(result_ab));
    expect(t, m.is_vector(result_ba));

    expect(t, result_ab == expected_ab);
    expect(t, m.eq(result_ab, expected_ab));
    expect(t, result_ba == expected_ba);
    expect(t, m.eq(result_ba, expected_ba));
}

@test
Matrix4_Construction :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    M :: m.Matrix4 { 1,    2,    3,    4,
                     5.5,  6.5,  7.5,  8.5,
                     9,    10,   11,   12,
                     13.5, 14.5, 15.5, 16.5 };

    expect(t, M[0, 0] == 1);
    expect(t, M[0, 3] == 4);
    expect(t, M[1, 0] == 5.5);
    expect(t, M[1, 2] == 7.5);
    expect(t, M[2, 2] == 11);
    expect(t, M[3, 0] == 13.5);
    expect(t, M[3, 2] == 15.5);

    M2 := m.matrix4(1,    2,    3,    4,
                    5.5,  6.5,  7.5,  8.5,
                    9,    10,   11,   12,
                    13.5, 14.5, 15.5, 16.5);

    expect(t, M2[0, 0] == 1);
    expect(t, M2[0, 3] == 4);
    expect(t, M2[1, 0] == 5.5);
    expect(t, M2[1, 2] == 7.5);
    expect(t, M2[2, 2] == 11);
    expect(t, M2[3, 0] == 13.5);
    expect(t, M2[3, 2] == 15.5);
}

@test
Matrix3_Construction :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    M :: m.Matrix3 { -3,  5,  0,
                      1, -2, -7,
                      0,  1,  1 };

    expect(t, M[0, 0] == -3);
    expect(t, M[1, 1] == -2);
    expect(t, M[2, 2] == 1);

    M2 := m.matrix3(-3,  5,  0,
                     1, -2, -7,
                     0,  1,  1);

    expect(t, M2[0, 0] == -3);
    expect(t, M2[1, 1] == -2);
    expect(t, M2[2, 2] == 1);
}

@test
Matrix2_Construction :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    M :: m.Matrix2 { -3,  5,
                      1, -2 };

    expect(t, M[0, 0] == -3);
    expect(t, M[0, 1] == 5);
    expect(t, M[1, 0] == 1);
    expect(t, M[1, 1] == -2);

    M2 := m.matrix2(-3,  5,
                     1, -2);

    expect(t, M2[0, 0] == -3);
    expect(t, M2[0, 1] == 5);
    expect(t, M2[1, 0] == 1);
    expect(t, M2[1, 1] == -2);
}

@test
Matrix4_Equality :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    B :: m.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    expect(t, A == B);
    expect(t, m.eq(A, B));
}

@test
Matrix4_Inequality :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    B :: m.Matrix4 { 2, 3, 4, 5,
                     6, 7, 8, 9,
                     8, 7, 6, 5,
                     4, 3, 2, 1 };

    expect(t, A != B);
    expect(t, !m.eq(A, B));
}

@test
Matrix3_Equality :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix3 { 1, 2, 3,
                     5, 6, 7,
                     9, 8, 7 };

    B :: m.Matrix3 { 1, 2, 3,
                     5, 6, 7,
                     9, 8, 7 };

    expect(t, A == B);
    expect(t, m.eq(A, B));
}

@test
Matrix3_Inequality :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix3 { 1, 2, 3,
                     5, 6, 7,
                     9, 8, 7 };

    B :: m.Matrix3 { 2, 3, 4,
                     6, 7, 8,
                     8, 7, 6 };

    expect(t, A != B);
    expect(t, !m.eq(A, B));
}

@test
Matrix2_Equality :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix2 { 1, 2,
                     5, 6 };

    B :: m.Matrix2 { 1, 2,
                     5, 6 };

    expect(t, A == B);
    expect(t, m.eq(A, B));
}

@test
Matrix2_Inequality :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix2 { 1, 2,
                     5, 6 };

    B :: m.Matrix2 { 2, 3,
                     6, 7 };

    expect(t, A != B);
    expect(t, !m.eq(A, B));
}

@test
Matrix4_Multiply :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    B :: m.Matrix4 { -2, 1, 2,  3,
                      3, 2, 1, -1,
                      4, 3, 6,  5,
                      1, 2, 7,  8 };

    expected :: m.Matrix4 { 20, 22,  50,  48,
                            44, 54, 114, 108,
                            40, 58, 110, 102,
                            16, 26,  46,  42 };

    result1 := A * B;

    result2 := m.mul(A, B);

    expect(t, result1 == expected);
    expect(t, m.eq(result1, expected));

    expect(t, result2 == expected);
    expect(t, m.eq(result2, expected));
}

@test
Matrix4_Multiply_Tuple :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    A :: m.Matrix4 { 1, 2, 3, 4,
                     2, 4, 4, 2,
                     8, 6, 4, 1,
                     0, 0, 0, 1 };

    b :: m.Tuple { 1, 2, 3, 1 };

    expected :: m.Tuple { 18, 24, 33, 1 };

    result1 := A * b;
    result2 := m.mul(A, b);

    expect(t, result1 == expected);
    expect(t, m.eq(result1, expected));

    expect(t, result2 == expected);
    expect(t, m.eq(result2, expected));

}

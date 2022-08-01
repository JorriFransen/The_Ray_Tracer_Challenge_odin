package tests

import "core:fmt"
import "core:testing"
import "core:intrinsics"
import cm "core:math"

import m "../src/rtmath"

math_suite := Test_Suite {
    name = "Math/",
    tests = { },
    child_suites = {
        &tuple_suite,
        &matrix_suite,
    },
}

tuple_suite := Test_Suite {
    name = "Tuple/",
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
    },
}

matrix_suite := Test_Suite {
    name = "Matrix/",
    tests = {
        test("M4_Construction", M4_Construction),
        test("M3_Construction", M3_Construction),
        test("M2_Construction", M2_Construction),
        test("M4_Equality", M4_Equality),
        test("M4_Inequality", M4_Inequality),
        test("M3_Equality", M3_Equality),
        test("M3_Inequality", M3_Inequality),
        test("M2_Equality", M2_Equality),
        test("M2_Inequality", M2_Inequality),
        test("M4_Multiply", M4_Multiply),
        test("M4_Multiply_Tuple", M4_Multiply_Tuple),
        test("M4_Multiply_Identity", M4_Multiply_Identity),
        test("M4_Multiply_Identity_Tuple", M4_Multiply_Identity_Tuple),
        test("M4_Transpose", M4_Transpose),
        test("M4_Transpose_Identity", M4_Transpose_Identity),
        test("M2_Determinant", Matrix2_Determinant),
        test("M3_Submatrix", Matrix3_Submatrix),
        test("M4_Submatrix", M4_Submatrix),
        test("M3_Minor", Matrix3_Minor),
        test("M3_Cofactor", Matrix3_Cofactor),
    },
}

@test
T_Is_Point :: proc(t: ^testing.T) {

    a := m.tuple(4.3, -4.2, 3.1, 1.0);

    expect(t, a.x == 4.3);
    expect(t, a.y == -4.2);
    expect(t, a.z == 3.1);
    expect(t, a.w == 1.0);

    expect(t, m.is_point(a));
    expect(t, !m.is_vector(a));
}

@test
T_Is_Vector :: proc(t: ^testing.T) {

    a := m.tuple(4.3, -4.2, 3.1, 0.0);

    expect(t, a.x == 4.3);
    expect(t, a.y == -4.2);
    expect(t, a.z == 3.1);
    expect(t, a.w == 0.0);

    expect(t, m.is_vector(a));
    expect(t, !m.is_point(a));
}

@test
P_Constructor :: proc(t: ^testing.T) {

    p := m.point(4, -4, 3);

    expected := m.tuple(4, -4, 3, 1);

    expect(t, m.is_point(p));
    expect(t, transmute(m.Tuple)p == expected);
    expect(t, p == transmute(m.Point)expected);
    expect(t, m.eq(p, expected));
}

@test
V_Constructor :: proc(t: ^testing.T) {

    v := m.vector(4, -4, 3);

    expected := m.tuple(4, -4, 3, 0);

    expect(t, m.is_vector(v));
    expect(t, transmute(m.Tuple)v == expected);
    expect(t, v == transmute(m.Vector)expected);
    expect(t, m.eq(v, expected));
}

@test
T_Add :: proc(t: ^testing.T) {

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
P_Add_Vector :: proc(t: ^testing.T) {

    p := m.point(3, -2, 5);
    v := m.vector(-2, 3, 1);

    expected := m.point(1, 1, 6);
    result : m.Point = m.add(p, v);

    expect(t, m.is_point(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
V_Add_Point :: proc(t: ^testing.T) {

    v := m.vector(3, -2, 5);
    p := m.point(-2, 3, 1);

    expected := m.point(1, 1, 6);
    result : m.Point = m.add(v, p);

    expect(t, m.is_point(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
V_Add :: proc(t: ^testing.T) {

    v1 := m.vector(3, -2, 5);
    v2 := m.vector(-2, 3, 1);

    expected := m.vector(1, 1, 6);
    result : m.Vector = m.add(v1, v2);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
T_Sub :: proc(t: ^testing.T) {

    a := m.tuple(3, 2, 1, 1);
    b := m.tuple(5, 6, 7, 1);

    expected := m.tuple(-2, -4, -6, 0);
    result := m.sub(a, b);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
P_Sub :: proc(t: ^testing.T) {

    a := m.point(3, 2, 1);
    b := m.point(5, 6, 7);

    expected := m.vector(-2, -4, -6);
    result : m.Vector = m.sub(a, b);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
P_Sub_Vector :: proc(t: ^testing.T) {

    p := m.point(3, 2, 1);
    v := m.vector(5, 6, 7);

    expected := m.point(-2, -4, -6);
    result : m.Point = m.sub(p, v);

    expect(t, m.is_point(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
V_Sub :: proc(t: ^testing.T) {

    v1 := m.vector(3, 2, 1);
    v2 := m.vector(5, 6, 7);

    expected := m.vector(-2, -4, -6);
    result : m.Vector = m.sub(v1, v2);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}


@test
V_Sub_From_Zero :: proc(t: ^testing.T) {

    zero := m.vector(0, 0, 0);
    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result : m.Vector = m.sub(zero, v);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
T_Negate :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(-1, 2, -3, 4);
    result := m.negate(a);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
V_Negate :: proc(t: ^testing.T) {

    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result : m.Vector = m.negate(v);

    expect(t, m.is_vector(result));
    expect(t, m.eq(result, expected));
}

@test
T_Mul_Scalar :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(3.5, -7, 10.5, -14);
    result := m.mul(a, 3.5);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
T_Mul_Fraction :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(0.5, -1, 1.5, -2);
    result := m.mul(a, 0.5);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
T_Div_Scalar :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(0.5, -1, 1.5, -2);
    result := m.div(a, 2);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
V_Magnitude_X1 :: proc(t: ^testing.T) {

    v := m.vector(1, 0, 0);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_Y1 :: proc(t: ^testing.T) {

    v := m.vector(0, 1, 0);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_Z1 :: proc(t: ^testing.T) {

    v := m.vector(0, 0, 1);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_X1_Y2_Z3 :: proc(t: ^testing.T) {

    v := m.vector(1, 2, 3);

    expected := cm.sqrt(intrinsics.type_field_type(m.Vector, "x")(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
V_Magnitude_X1_Y2_Z3_Neg :: proc(t: ^testing.T) {

    v := m.vector(-1, -2, -3);

    expected := cm.sqrt(intrinsics.type_field_type(m.Vector, "x")(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
V_Normalize_X4 :: proc(t: ^testing.T) {

    v := m.vector(4, 0, 0);

    expected := m.vector(1, 0, 0);
    result := m.normalize(v);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
V_Normalize_X1_Y2_Z3 :: proc(t: ^testing.T) {

    v := m.vector(1, 2, 3);

    // 1*1 + 2*2 + 3*3 = 14
    /*expected := m.vector(1 / cm.sqrt(f32(14)), 2 / cm.sqrt(f32(14)), 3 / cm.sqrt(f32(14)));*/
    expected := m.vector(0.267271, 0.53452, 0.80178);
    result := m.normalize(v);

    /*expect(t, result == expected);*/
    expect(t, m.eq(result, expected));
}

@test
V_Dot :: proc(t: ^testing.T) {

    a := m.vector(1, 2, 3);
    b := m.vector(2, 3, 4);

    expected :: 20.0;
    result := m.dot(a, b);

    expect(t, result == expected);
}

@test
V_Cross :: proc(t: ^testing.T) {

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
M4_Construction :: proc(t: ^testing.T) {

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
M3_Construction :: proc(t: ^testing.T) {

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
M2_Construction :: proc(t: ^testing.T) {

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
M4_Equality :: proc(t: ^testing.T) {

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
M4_Inequality :: proc(t: ^testing.T) {

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
M3_Equality :: proc(t: ^testing.T) {

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
M3_Inequality :: proc(t: ^testing.T) {

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
M2_Equality :: proc(t: ^testing.T) {

    A :: m.Matrix2 { 1, 2,
                     5, 6 };

    B :: m.Matrix2 { 1, 2,
                     5, 6 };

    expect(t, A == B);
    expect(t, m.eq(A, B));
}

@test
M2_Inequality :: proc(t: ^testing.T) {

    A :: m.Matrix2 { 1, 2,
                     5, 6 };

    B :: m.Matrix2 { 2, 3,
                     6, 7 };

    expect(t, A != B);
    expect(t, !m.eq(A, B));
}

@test
M4_Multiply :: proc(t: ^testing.T) {

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
M4_Multiply_Tuple :: proc(t: ^testing.T) {

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

@test
M4_Multiply_Identity :: proc(t: ^testing.T) {

    A :: m.Matrix4 {
        0, 1,  2,  4,
        1, 2,  4,  8,
        2, 4,  8, 16,
        4, 8, 16, 32,
    };

    result1 := A * m.matrix4_identity;
    result2 := m.mul(A, m.matrix4_identity);

    expect(t, result1 == A);
    expect(t, m.eq(result1, A));

    expect(t, result2 == A);
    expect(t, m.eq(result2, A));
}

@test
M4_Multiply_Identity_Tuple :: proc(t: ^testing.T) {

    a := m.Tuple { 1, 2, 3, 4 };

    result1 := m.matrix4_identity * a;
    result2 := m.mul(m.matrix4_identity, a);

    expect(t, result1 == a);
    expect(t, m.eq(result1, a));

    expect(t, result2 == a);
    expect(t, m.eq(result2, a));
}

@test
M4_Transpose :: proc(t: ^testing.T) {

    A :: m.Matrix4 {
        0, 9, 3, 0,
        9, 8, 0, 8,
        1, 8, 5, 3,
        0, 0, 5, 8
    };

    expected :: m.Matrix4 {
        0, 9, 1, 0,
        9, 8, 8, 0,
        3, 0, 5, 5,
        0, 8, 3, 8
    };

    result1 := m.Matrix4(transpose(A));
    result2 := m.matrix_transpose(A);

    expect(t, result1 == expected);
    expect(t, m.eq(result1, expected));

    expect(t, result2 == expected);
    expect(t, m.eq(result2, expected));
}

@test
M4_Transpose_Identity :: proc(t: ^testing.T) {

    A := m.matrix_transpose(m.matrix4_identity);

    expect(t, A == m.matrix4_identity);
    expect(t, m.eq(A, m.matrix4_identity));
}

@test
Matrix2_Determinant :: proc(t: ^testing.T) {

    A :: m.Matrix2 {
         1, 5,
        -3, 2
    };

    expected :: 17;

    result1 := determinant(A);
    result2 := m.matrix_determinant(A);

    expect(t, result1 == expected);
    expect(t, m.eq(result1, expected));

    expect(t, result2 == expected);
    expect(t, m.eq(result2, expected));
}


@test
Matrix3_Submatrix :: proc(t: ^testing.T) {

    A :: m.Matrix3 {
         1, 5, 0,
        -3, 2, 7,
         0, 6, 3
    };

    expected1 :: m.Matrix2 {
        -3, 2,
         0, 6,
    };

    expected2 :: m.Matrix2 {
         1, 5,
        -3, 2,
    };

    result1 := m.matrix_submatrix(A, 0, 2);
    result2 := m.matrix_submatrix(A, 2, 2);

    expect(t, result1 == expected1);
    expect(t, m.eq(result1, expected1));

    expect(t, result2 == expected2);
    expect(t, m.eq(result2, expected2));
}

@test
M4_Submatrix :: proc(t: ^testing.T) {

    A :: m.Matrix4 {
        -6, 1,  1, 6,
        -8, 5,  8, 6,
        -1, 0,  8, 2,
        -7, 1, -1, 1,
    };

    expected1 :: m.Matrix3 {
        -6,  1, 6,
        -8,  8, 6,
        -7, -1, 1,
    };

    expected2 :: m.Matrix3 {
        -6, 1, 1,
        -8, 5, 8,
        -1, 0, 8,
    };

    result1 := m.matrix_submatrix(A, 2, 1);
    result2 := m.matrix_submatrix(A, 3, 3);

    expect(t, result1 == expected1);
    expect(t, m.eq(result1, expected1));

    expect(t, result2 == expected2);
    expect(t, m.eq(result2, expected2));
}

@test
Matrix3_Minor :: proc(t: ^testing.T) {

    A :: m.Matrix3 {
        3,  5,  0,
        2, -1, -7,
        6, -1,  5,
    };

    row, col :: 1, 0;

    B := m.matrix_submatrix(A, row, col);

    expected_determinant : m.Matrix_Element_Type : 25;
    result_determinant := m.matrix_determinant(B);

    expect(t, result_determinant == expected_determinant);


    expected_minor :: 25;
    result_minor := m.matrix_minor(A, row, col);

    expect(t, expected_minor == result_minor);

}

@test
Matrix3_Cofactor :: proc(t: ^testing.T) {

    A :: m.Matrix3 {
        3,  5,  0,
        2, -1, -7,
        6, -1,  5
    };

    expect(t, m.matrix_minor(A, 0, 0) == -12);
    expect(t, m.matrix_cofactor(A, 0, 0) == -12);
    expect(t, m.matrix_minor(A, 1, 0) == 25);
    expect(t, m.matrix_cofactor(A, 1, 0) == -25);
}

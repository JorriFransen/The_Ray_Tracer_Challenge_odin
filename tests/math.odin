package tests

import "core:fmt"
import "core:testing"
import "core:intrinsics"
import cm "core:math"

import m "../src/rtmath"

math_suite := &Test_Suite {
    name = "Math/",
    tests = {
        Test { {"tests", "failing_test", failing_test } },
        Test { {"tests", "Tuple_Is_Point", Tuple_Is_Point } },
        Test { {"tests", "Tuple_Is_Vector", Tuple_Is_Vector } },
        Test { {"tests", "Point_Constructor", Point_Constructor } },
        Test { {"tests", "Vector_Constructor", Vector_Constructor } },
        Test { {"tests", "Tuple_Add", Tuple_Add } },
        Test { {"tests", "Add_Point_And_Vector", Add_Point_And_Vector } },
        Test { {"tests", "Add_Vector_And_Point", Add_Vector_And_Point } },
        Test { {"tests", "Vector_Add", Vector_Add } },
        Test { {"tests", "Tuple_Sub", Tuple_Sub } },
        Test { {"tests", "Point_Sub", Point_Sub } },
        Test { {"tests", "Point_Sub_Vector", Point_Sub_Vector } },
        Test { {"tests", "Vector_Sub", Vector_Sub } },
        Test { {"tests", "Vector_Sub_From_Zero", Vector_Sub_From_Zero } },
        Test { {"tests", "Tuple_Negate", Tuple_Negate } },
        Test { {"tests", "Vector_Negate", Vector_Negate } },
        Test { {"tests", "Tuple_Mul_Scalar", Tuple_Mul_Scalar } },
        Test { {"tests", "Tuple_Mul_Fraction", Tuple_Mul_Fraction } },
        Test { {"tests", "Tuple_Div_Scalar", Tuple_Div_Scalar } },
        Test { {"tests", "Vector_Magnitude_X1", Vector_Magnitude_X1 } },
        Test { {"tests", "Vector_Magnitude_Y1", Vector_Magnitude_Y1 } },
        Test { {"tests", "Vector_Magnitude_Z1", Vector_Magnitude_Z1 } },
        Test { {"tests", "Vector_Magnitude_X1_Y2_Z3", Vector_Magnitude_X1_Y2_Z3 } },
        Test { {"tests", "Vector_Magnitude_X1_Y2_Z3_Neg", Vector_Magnitude_X1_Y2_Z3_Neg } },
        Test { {"tests", "Vector_Normalize_X4", Vector_Normalize_X4 } },
        Test { {"tests", "Vector_Normalize_X1_Y2_Z3", Vector_Normalize_X1_Y2_Z3 } },
        Test { {"tests", "Vector_Dot", Vector_Dot } },
        Test { {"tests", "Vector_Cross", Vector_Cross } },
        Test { {"tests", "Matrix4_Construction", Matrix4_Construction } },
        Test { {"tests", "Matrix3_Construction", Matrix3_Construction } },
        Test { {"tests", "Matrix2_Construction", Matrix2_Construction } },
        Test { {"tests", "Matrix4_Equality", Matrix4_Equality } },
        Test { {"tests", "Matrix4_Inequality", Matrix4_Inequality } },
        Test { {"tests", "Matrix3_Equality", Matrix3_Equality } },
        Test { {"tests", "Matrix3_Inequality", Matrix3_Inequality } },
        Test { {"tests", "Matrix2_Equality", Matrix2_Equality } },
        Test { {"tests", "Matrix2_Inequality", Matrix2_Inequality } },
        Test { {"tests", "Matrix4_Multiply", Matrix4_Multiply } },
        Test { {"tests", "Matrix4_Multiply_Tuple", Matrix4_Multiply_Tuple } },
        Test { {"tests", "Matrix4_Multiply_Identity", Matrix4_Multiply_Identity } },
        Test { {"tests", "Matrix4_Multiply_Identity_Tuple", Matrix4_Multiply_Identity_Tuple } },
        Test { {"tests", "Matrix4_Transpose", Matrix4_Transpose } },
        Test { {"tests", "Matrix4_Transpose_Identity", Matrix4_Transpose_Identity } },
        Test { {"tests", "Matrix2_Determinant", Matrix2_Determinant } },
        Test { {"tests", "Matrix3_Submatrix", Matrix3_Submatrix } },
        Test { {"tests", "Matrix4_Submatrix", Matrix4_Submatrix } },
        Test { {"tests", "Matrix3_Minor", Matrix3_Minor } },
        Test { {"tests", "Matrix3_Cofactor", Matrix3_Cofactor } },

    },
}

@test
failing_test :: proc(t: ^testing.T) {
    // expect(t, false, "dummy failing test...");
    // expect(t, false, "another failing condition in the same test...");
}

@test
Tuple_Is_Point :: proc(t: ^testing.T) {

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

    p := m.point(4, -4, 3);

    expected := m.tuple(4, -4, 3, 1);

    expect(t, m.is_point(p));
    expect(t, transmute(m.Tuple)p == expected);
    expect(t, p == transmute(m.Point)expected);
    expect(t, m.eq(p, expected));
}

@test
Vector_Constructor :: proc(t: ^testing.T) {

    v := m.vector(4, -4, 3);

    expected := m.tuple(4, -4, 3, 0);

    expect(t, m.is_vector(v));
    expect(t, transmute(m.Tuple)v == expected);
    expect(t, v == transmute(m.Vector)expected);
    expect(t, m.eq(v, expected));
}

@test
Tuple_Add :: proc(t: ^testing.T) {

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

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(-1, 2, -3, 4);
    result := m.negate(a);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Negate :: proc(t: ^testing.T) {

    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result : m.Vector = m.negate(v);

    expect(t, m.is_vector(result));
    expect(t, m.eq(result, expected));
}

@test
Tuple_Mul_Scalar :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(3.5, -7, 10.5, -14);
    result := m.mul(a, 3.5);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Tuple_Mul_Fraction :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(0.5, -1, 1.5, -2);
    result := m.mul(a, 0.5);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Tuple_Div_Scalar :: proc(t: ^testing.T) {

    a := m.tuple(1, -2, 3, -4);

    expected := m.tuple(0.5, -1, 1.5, -2);
    result := m.div(a, 2);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Magnitude_X1 :: proc(t: ^testing.T) {

    v := m.vector(1, 0, 0);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_Y1 :: proc(t: ^testing.T) {

    v := m.vector(0, 1, 0);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_Z1 :: proc(t: ^testing.T) {

    v := m.vector(0, 0, 1);

    expected :: 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1_Y2_Z3 :: proc(t: ^testing.T) {

    v := m.vector(1, 2, 3);

    expected := cm.sqrt(intrinsics.type_field_type(m.Vector, "x")(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1_Y2_Z3_Neg :: proc(t: ^testing.T) {

    v := m.vector(-1, -2, -3);

    expected := cm.sqrt(intrinsics.type_field_type(m.Vector, "x")(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Normalize_X4 :: proc(t: ^testing.T) {

    v := m.vector(4, 0, 0);

    expected := m.vector(1, 0, 0);
    result := m.normalize(v);

    expect(t, result == expected);
    expect(t, m.eq(result, expected));
}

@test
Vector_Normalize_X1_Y2_Z3 :: proc(t: ^testing.T) {

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

    a := m.vector(1, 2, 3);
    b := m.vector(2, 3, 4);

    expected :: 20.0;
    result := m.dot(a, b);

    expect(t, result == expected);
}

@test
Vector_Cross :: proc(t: ^testing.T) {

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

    A :: m.Matrix2 { 1, 2,
                     5, 6 };

    B :: m.Matrix2 { 1, 2,
                     5, 6 };

    expect(t, A == B);
    expect(t, m.eq(A, B));
}

@test
Matrix2_Inequality :: proc(t: ^testing.T) {

    A :: m.Matrix2 { 1, 2,
                     5, 6 };

    B :: m.Matrix2 { 2, 3,
                     6, 7 };

    expect(t, A != B);
    expect(t, !m.eq(A, B));
}

@test
Matrix4_Multiply :: proc(t: ^testing.T) {

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
Matrix4_Multiply_Identity :: proc(t: ^testing.T) {

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
Matrix4_Multiply_Identity_Tuple :: proc(t: ^testing.T) {

    a := m.Tuple { 1, 2, 3, 4 };

    result1 := m.matrix4_identity * a;
    result2 := m.mul(m.matrix4_identity, a);

    expect(t, result1 == a);
    expect(t, m.eq(result1, a));

    expect(t, result2 == a);
    expect(t, m.eq(result2, a));
}

@test
Matrix4_Transpose :: proc(t: ^testing.T) {

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
Matrix4_Transpose_Identity :: proc(t: ^testing.T) {

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
Matrix4_Submatrix :: proc(t: ^testing.T) {

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

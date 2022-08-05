package tests_math

import "core:testing";

import rm "raytracer:math";

import r "../runner"

matrix_suite := r.Test_Suite {
    name = "Mtx/",
    tests = {
        r.test("M4_Construction", M4_Construction),
        r.test("M3_Construction", M3_Construction),
        r.test("M2_Construction", M2_Construction),
        r.test("M4_Equality", M4_Equality),
        r.test("M4_Inequality", M4_Inequality),
        r.test("M3_Equality", M3_Equality),
        r.test("M3_Inequality", M3_Inequality),
        r.test("M2_Equality", M2_Equality),
        r.test("M2_Inequality", M2_Inequality),
        r.test("M4_Multiply", M4_Multiply),
        r.test("M4_Multiply_Tuple", M4_Multiply_Tuple),
        r.test("M4_Multiply_Identity", M4_Multiply_Identity),
        r.test("M4_Multiply_Identity_Tuple", M4_Multiply_Identity_Tuple),
        r.test("M4_Transpose", M4_Transpose),
        r.test("M4_Transpose_Identity", M4_Transpose_Identity),
        r.test("M2_Determinant", M2_Determinant),
        r.test("M3_Submatrix", M3_Submatrix),
        r.test("M4_Submatrix", M4_Submatrix),
        r.test("M3_Minor", M3_Minor),
        r.test("M3_Cofactor", M3_Cofactor),
        r.test("M3_Determinant", M3_Determinant),
        r.test("M4_Determinant", M4_Determinant),
        r.test("M4_Invertible", M4_Invertible),
        r.test("M4_Non_Invertible", M4_Non_Invertible),
        r.test("M4_Inverse1", M4_Inverse1),
        r.test("M4_Inverse2", M4_Inverse2),
        r.test("M4_Inverse3", M4_Inverse3),
        r.test("M4_Mul_Prod_Inverse", M4_Mul_Prod_Inverse),
    },
}

@test
M4_Construction :: proc(t: ^testing.T) {

    M :: rm.Matrix4 { 1,    2,    3,    4,
                     5.5,  6.5,  7.5,  8.5,
                     9,    10,   11,   12,
                     13.5, 14.5, 15.5, 16.5 };

    r.expect(t, M[0, 0] == 1);
    r.expect(t, M[0, 3] == 4);
    r.expect(t, M[1, 0] == 5.5);
    r.expect(t, M[1, 2] == 7.5);
    r.expect(t, M[2, 2] == 11);
    r.expect(t, M[3, 0] == 13.5);
    r.expect(t, M[3, 2] == 15.5);

    M2 := rm.matrix4(1,    2,    3,    4,
                    5.5,  6.5,  7.5,  8.5,
                    9,    10,   11,   12,
                    13.5, 14.5, 15.5, 16.5);

    r.expect(t, M2[0, 0] == 1);
    r.expect(t, M2[0, 3] == 4);
    r.expect(t, M2[1, 0] == 5.5);
    r.expect(t, M2[1, 2] == 7.5);
    r.expect(t, M2[2, 2] == 11);
    r.expect(t, M2[3, 0] == 13.5);
    r.expect(t, M2[3, 2] == 15.5);
}

@test
M3_Construction :: proc(t: ^testing.T) {

    M :: rm.Matrix3 { -3,  5,  0,
                      1, -2, -7,
                      0,  1,  1 };

    r.expect(t, M[0, 0] == -3);
    r.expect(t, M[1, 1] == -2);
    r.expect(t, M[2, 2] == 1);

    M2 := rm.matrix3(-3,  5,  0,
                     1, -2, -7,
                     0,  1,  1);

    r.expect(t, M2[0, 0] == -3);
    r.expect(t, M2[1, 1] == -2);
    r.expect(t, M2[2, 2] == 1);
}

@test
M2_Construction :: proc(t: ^testing.T) {

    M :: rm.Matrix2 { -3,  5,
                      1, -2 };

    r.expect(t, M[0, 0] == -3);
    r.expect(t, M[0, 1] == 5);
    r.expect(t, M[1, 0] == 1);
    r.expect(t, M[1, 1] == -2);

    M2 := rm.matrix2(-3,  5,
                     1, -2);

    r.expect(t, M2[0, 0] == -3);
    r.expect(t, M2[0, 1] == 5);
    r.expect(t, M2[1, 0] == 1);
    r.expect(t, M2[1, 1] == -2);
}

@test
M4_Equality :: proc(t: ^testing.T) {

    A :: rm.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    B :: rm.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    r.expect(t, A == B);
    r.expect(t, rm.eq(A, B));
}

@test
M4_Inequality :: proc(t: ^testing.T) {

    A :: rm.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    B :: rm.Matrix4 { 2, 3, 4, 5,
                     6, 7, 8, 9,
                     8, 7, 6, 5,
                     4, 3, 2, 1 };

    r.expect(t, A != B);
    r.expect(t, !rm.eq(A, B));
}

@test
M3_Equality :: proc(t: ^testing.T) {

    A :: rm.Matrix3 { 1, 2, 3,
                     5, 6, 7,
                     9, 8, 7 };

    B :: rm.Matrix3 { 1, 2, 3,
                     5, 6, 7,
                     9, 8, 7 };

    r.expect(t, A == B);
    r.expect(t, rm.eq(A, B));
}

@test
M3_Inequality :: proc(t: ^testing.T) {

    A :: rm.Matrix3 { 1, 2, 3,
                     5, 6, 7,
                     9, 8, 7 };

    B :: rm.Matrix3 { 2, 3, 4,
                     6, 7, 8,
                     8, 7, 6 };

    r.expect(t, A != B);
    r.expect(t, !rm.eq(A, B));
}

@test
M2_Equality :: proc(t: ^testing.T) {

    A :: rm.Matrix2 { 1, 2,
                     5, 6 };

    B :: rm.Matrix2 { 1, 2,
                     5, 6 };

    r.expect(t, A == B);
    r.expect(t, rm.eq(A, B));
}

@test
M2_Inequality :: proc(t: ^testing.T) {

    A :: rm.Matrix2 { 1, 2,
                     5, 6 };

    B :: rm.Matrix2 { 2, 3,
                     6, 7 };

    r.expect(t, A != B);
    r.expect(t, !rm.eq(A, B));
}

@test
M4_Multiply :: proc(t: ^testing.T) {

    A :: rm.Matrix4 { 1, 2, 3, 4,
                     5, 6, 7, 8,
                     9, 8, 7, 6,
                     5, 4, 3, 2 };

    B :: rm.Matrix4 { -2, 1, 2,  3,
                      3, 2, 1, -1,
                      4, 3, 6,  5,
                      1, 2, 7,  8 };

    expected :: rm.Matrix4 { 20, 22,  50,  48,
                            44, 54, 114, 108,
                            40, 58, 110, 102,
                            16, 26,  46,  42 };

    result1 := A * B;

    result2 := rm.mul(A, B);

    r.expect(t, result1 == expected);
    r.expect(t, rm.eq(result1, expected));

    r.expect(t, result2 == expected);
    r.expect(t, rm.eq(result2, expected));
}

@test
M4_Multiply_Tuple :: proc(t: ^testing.T) {

    A :: rm.Matrix4 { 1, 2, 3, 4,
                     2, 4, 4, 2,
                     8, 6, 4, 1,
                     0, 0, 0, 1 };

    b :: rm.Tuple { 1, 2, 3, 1 };

    expected :: rm.Tuple { 18, 24, 33, 1 };

    result1 := A * b;
    result2 := rm.mul(A, b);

    r.expect(t, result1 == expected);
    r.expect(t, rm.eq(result1, expected));

    r.expect(t, result2 == expected);
    r.expect(t, rm.eq(result2, expected));

}

@test
M4_Multiply_Identity :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
        0, 1,  2,  4,
        1, 2,  4,  8,
        2, 4,  8, 16,
        4, 8, 16, 32,
    };

    result1 := A * rm.matrix4_identity;
    result2 := rm.mul(A, rm.matrix4_identity);

    r.expect(t, result1 == A);
    r.expect(t, rm.eq(result1, A));

    r.expect(t, result2 == A);
    r.expect(t, rm.eq(result2, A));
}

@test
M4_Multiply_Identity_Tuple :: proc(t: ^testing.T) {

    a := rm.Tuple { 1, 2, 3, 4 };

    result1 := rm.matrix4_identity * a;
    result2 := rm.mul(rm.matrix4_identity, a);

    r.expect(t, result1 == a);
    r.expect(t, rm.eq(result1, a));

    r.expect(t, result2 == a);
    r.expect(t, rm.eq(result2, a));
}

@test
M4_Transpose :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
        0, 9, 3, 0,
        9, 8, 0, 8,
        1, 8, 5, 3,
        0, 0, 5, 8,
    };

    expected :: rm.Matrix4 {
        0, 9, 1, 0,
        9, 8, 8, 0,
        3, 0, 5, 5,
        0, 8, 3, 8,
    };

    result1 := rm.Matrix4(transpose(A));
    result2 := rm.matrix_transpose(A);

    r.expect(t, result1 == expected);
    r.expect(t, rm.eq(result1, expected));

    r.expect(t, result2 == expected);
    r.expect(t, rm.eq(result2, expected));
}

@test
M4_Transpose_Identity :: proc(t: ^testing.T) {

    A := rm.matrix_transpose(rm.matrix4_identity);

    r.expect(t, A == rm.matrix4_identity);
    r.expect(t, rm.eq(A, rm.matrix4_identity));
}

@test
M2_Determinant :: proc(t: ^testing.T) {

    A :: rm.Matrix2 {
         1, 5,
        -3, 2,
    };

    expected :: 17;

    result1 := determinant(A);
    result2 := rm.matrix_determinant(A);

    r.expect(t, result1 == expected);
    r.expect(t, rm.eq(result1, expected));

    r.expect(t, result2 == expected);
    r.expect(t, rm.eq(result2, expected));
}


@test
M3_Submatrix :: proc(t: ^testing.T) {

    A :: rm.Matrix3 {
         1, 5, 0,
        -3, 2, 7,
         0, 6, 3,
    };

    expected1 :: rm.Matrix2 {
        -3, 2,
         0, 6,
    };

    expected2 :: rm.Matrix2 {
         1, 5,
        -3, 2,
    };

    result1 := rm.matrix_submatrix(A, 0, 2);
    result2 := rm.matrix_submatrix(A, 2, 2);

    r.expect(t, result1 == expected1);
    r.expect(t, rm.eq(result1, expected1));

    r.expect(t, result2 == expected2);
    r.expect(t, rm.eq(result2, expected2));
}

@test
M4_Submatrix :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
        -6, 1,  1, 6,
        -8, 5,  8, 6,
        -1, 0,  8, 2,
        -7, 1, -1, 1,
    };

    expected1 :: rm.Matrix3 {
        -6,  1, 6,
        -8,  8, 6,
        -7, -1, 1,
    };

    expected2 :: rm.Matrix3 {
        -6, 1, 1,
        -8, 5, 8,
        -1, 0, 8,
    };

    result1 := rm.matrix_submatrix(A, 2, 1);
    result2 := rm.matrix_submatrix(A, 3, 3);

    r.expect(t, result1 == expected1);
    r.expect(t, rm.eq(result1, expected1));

    r.expect(t, result2 == expected2);
    r.expect(t, rm.eq(result2, expected2));
}

@test
M3_Minor :: proc(t: ^testing.T) {

    A :: rm.Matrix3 {
        3,  5,  0,
        2, -1, -7,
        6, -1,  5,
    };

    row, col :: 1, 0;

    B := rm.matrix_submatrix(A, row, col);

    expected_determinant : rm.real : 25;
    result_determinant := rm.matrix_determinant(B);

    r.expect(t, result_determinant == expected_determinant);


    expected_minor :: 25;
    result_minor := rm.matrix_minor(A, row, col);

    r.expect(t, expected_minor == result_minor);

}

@test
M3_Cofactor :: proc(t: ^testing.T) {

    A :: rm.Matrix3 {
        3,  5,  0,
        2, -1, -7,
        6, -1,  5,
    };

    r.expect(t, rm.matrix_minor(A, 0, 0) == -12);
    r.expect(t, rm.matrix_cofactor(A, 0, 0) == -12);
    r.expect(t, rm.matrix_minor(A, 1, 0) == 25);
    r.expect(t, rm.matrix_cofactor(A, 1, 0) == -25);
}

@test
M3_Determinant :: proc(t: ^testing.T) {

    A :: rm.Matrix3 {
         1, 2,  6,
        -5, 8, -4,
         2, 6,  4,
    };

    r.expect(t, rm.matrix_cofactor(A, 0, 0) == 56);
    r.expect(t, rm.matrix_cofactor(A, 0, 1) == 12);
    r.expect(t, rm.matrix_cofactor(A, 0, 2) == -46);
    r.expect(t, rm.matrix_determinant(A) == -196);

}

@test
M4_Determinant :: proc(t: ^testing.T) {

     A :: rm.Matrix4 {
         -2, -8,  3,  5,
         -3,  1,  7,  3,
          1,  2, -9,  6,
         -6,  7,  7, -9,
     };

     r.expect(t, rm.matrix_cofactor(A, 0, 0) == 690);
     r.expect(t, rm.matrix_cofactor(A, 0, 1) == 447);
     r.expect(t, rm.matrix_cofactor(A, 0, 2) == 210);
     r.expect(t, rm.matrix_cofactor(A, 0, 3) == 51);

     r.expect(t, rm.matrix_determinant(A) == -4071);
}

@test
M4_Invertible :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
        6,  4, 4,  4,
        5,  5, 7,  6,
        4, -9, 3, -7,
        9,  1, 7, -6,
    };

    r.expect(t, rm.matrix_determinant(A) == -2120);
    r.expect(t, rm.matrix_is_invertible(A));
}

@test
M4_Non_Invertible :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
        -4,  2, -2, -3,
         9,  6,  2,  6,
         0, -5,  1, -5,
         0,  0,  0,  0,
    };

    r.expect(t, rm.matrix_determinant(A) == 0);
    r.expect(t, rm.matrix_is_invertible(A) == false);
}

@test
M4_Inverse1 :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
        -5,  2,  6, -8,
         1, -5,  1,  8,
         7,  7, -6, -7,
         1, -3,  7,  4,
    };

    expected_b :: rm.Matrix4 {
         0.21805,  0.45113,  0.24060, -0.04511,
        -0.80827, -1.45677, -0.44361,  0.52068,
        -0.07895, -0.22368, -0.05263,  0.19737,
        -0.52256, -0.81391, -0.30075,  0.30639,
    };

    B := rm.matrix_inverse(A);

    r.expect(t, rm.matrix_determinant(A) == 532.0);

    r.expect(t, rm.matrix_cofactor(A, 0, 1) == -430.0);
    r.expect(t, rm.matrix_cofactor(A, 1, 0) == 240.0);
    r.expect(t, rm.matrix_cofactor(A, 2, 3) == -160.0);

    r.expect(t, rm.eq(B[3, 2], -160.0/532.0));

    r.expect(t, rm.matrix_cofactor(A, 3, 2) == 105.0);
    r.expect(t, rm.eq(B[2, 3], 105.0/532.0));

    r.expect(t, rm.eq(B, expected_b));
}

@test
M4_Inverse2 :: proc(t: ^testing.T) {
    A :: rm.Matrix4 {
         8, -5,  9,  2,
         7,  5,  6,  1,
        -6,  0,  9,  6,
        -3,  0, -9, -4,
    };

    expected :: rm.Matrix4 {
        -0.15385, -0.15385, -0.28205, -0.53846,
        -0.07692,  0.12308,  0.02564,  0.03077,
         0.35897,  0.35897,  0.43590,  0.92308,
        -0.69231, -0.69231, -0.76923, -1.92308,
    };

    result := rm.matrix_inverse(A);

    r.expect(t, rm.eq(result, expected));
}

@test
M4_Inverse3 :: proc(t: ^testing.T) {
    A :: rm.Matrix4 {
         9,  3,  0,  9,
        -5, -2, -6, -3,
        -4,  9,  6,  4,
        -7,  6,  6,  2,
    };

    expected :: rm.Matrix4 {
        -0.04074, -0.07778,  0.14444, -0.22222,
        -0.07778,  0.03333,  0.36667, -0.33333,
        -0.02901, -0.14630, -0.10926,  0.12963,
         0.17778,  0.06667, -0.26667,  0.33333,
    };

    result := rm.matrix_inverse(A);

    r.expect(t, rm.eq(result, expected));
}

@test
M4_Mul_Prod_Inverse :: proc(t: ^testing.T) {

    A :: rm.Matrix4 {
         3, -9,  7,  3,
         3, -8,  2, -9,
        -4,  4,  4,  1,
        -6,  5, -1,  1,
    };

    B :: rm.Matrix4 {
         8,  2,  2,  2,
         3, -1,  7,  0,
         7,  0,  5,  4,
         6, -2,  0,  5,
    };

    C1 := rm.mul(A, B);
    C2 := A * B;

    result1 := rm.mul(C1, rm.matrix_inverse(B));
    result2 := C1 * rm.matrix_inverse(B);

    r.expect(t, rm.eq(result1, A));
    r.expect(t, rm.eq(result2, A));
}

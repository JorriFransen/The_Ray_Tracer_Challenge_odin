package rtmath

import "core:fmt"
import "core:intrinsics"

Matrix4 :: distinct matrix[4, 4]real;
Matrix3 :: distinct matrix[3, 3]real;
Matrix2 :: distinct matrix[2, 2]real;

matrix4_identity :: Matrix4 { 1, 0, 0, 0,
                              0, 1, 0, 0,
                              0, 0, 1, 0,
                              0, 0, 0, 1 };

matrix4 :: proc(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33: real) -> Matrix4 {
    return Matrix4 { m00, m01, m02, m03,
                     m10, m11, m12, m13,
                     m20, m21, m22, m23,
                     m30, m31, m32, m33 };
}

matrix3 :: proc(m00, m01, m02, m10, m11, m12, m20, m21, m22: real) -> Matrix3 {
    return Matrix3 { m00, m01, m02,
                     m10, m11, m12,
                     m20, m21, m22 };
}

matrix2 :: proc(m00, m01, m10, m11: real) -> Matrix2 {
    return Matrix2 { m00, m01,
                     m10, m11 };
                 }

matrix4_eq :: proc(a, b: Matrix4) -> bool {
    Flat_Type :: [16]real;

    a_flat := transmute(Flat_Type)a;
    b_flat := transmute(Flat_Type)b;

    return eq_arr(a_flat, b_flat);
}

matrix3_eq :: proc(a, b: Matrix3) -> bool {
    Flat_Type :: [9]real;

    a_flat := transmute(Flat_Type)a;
    b_flat := transmute(Flat_Type)b;

    return eq_arr(a_flat, b_flat);
}

matrix2_eq :: proc(a, b: Matrix2) -> bool {
    Flat_Type :: [4]real

    a_flat := transmute(Flat_Type)a;
    b_flat := transmute(Flat_Type)b;

    return tuple_eq(a_flat, b_flat);
}

matrix4_mul :: proc(a, b: Matrix4) -> Matrix4 {
    return a * b;
    // return Matrix4 {
    //     a[0, 0] * b[0, 0] + a[0, 1] * b[1, 0] + a[0, 2] * b[2, 0] + a[0, 3] * b[3, 0],
    //     a[0, 0] * b[0, 1] + a[0, 1] * b[1, 1] + a[0, 2] * b[2, 1] + a[0, 3] * b[3, 1],
    //     a[0, 0] * b[0, 2] + a[0, 1] * b[1, 2] + a[0, 2] * b[2, 2] + a[0, 3] * b[3, 2],
    //     a[0, 0] * b[0, 3] + a[0, 1] * b[1, 3] + a[0, 2] * b[2, 3] + a[0, 3] * b[3, 3],

    //     a[1, 0] * b[0, 0] + a[1, 1] * b[1, 0] + a[1, 2] * b[2, 0] + a[1, 3] * b[3, 0],
    //     a[1, 0] * b[0, 1] + a[1, 1] * b[1, 1] + a[1, 2] * b[2, 1] + a[1, 3] * b[3, 1],
    //     a[1, 0] * b[0, 2] + a[1, 1] * b[1, 2] + a[1, 2] * b[2, 2] + a[1, 3] * b[3, 2],
    //     a[1, 0] * b[0, 3] + a[1, 1] * b[1, 3] + a[1, 2] * b[2, 3] + a[1, 3] * b[3, 3],

    //     a[2, 0] * b[0, 0] + a[2, 1] * b[1, 0] + a[2, 2] * b[2, 0] + a[2, 3] * b[3, 0],
    //     a[2, 0] * b[0, 1] + a[2, 1] * b[1, 1] + a[2, 2] * b[2, 1] + a[2, 3] * b[3, 1],
    //     a[2, 0] * b[0, 2] + a[2, 1] * b[1, 2] + a[2, 2] * b[2, 2] + a[2, 3] * b[3, 2],
    //     a[2, 0] * b[0, 3] + a[2, 1] * b[1, 3] + a[2, 2] * b[2, 3] + a[2, 3] * b[3, 3],

    //     a[3, 0] * b[0, 0] + a[3, 1] * b[1, 0] + a[3, 2] * b[2, 0] + a[3, 3] * b[3, 0],
    //     a[3, 0] * b[0, 1] + a[3, 1] * b[1, 1] + a[3, 2] * b[2, 1] + a[3, 3] * b[3, 1],
    //     a[3, 0] * b[0, 2] + a[3, 1] * b[1, 2] + a[3, 2] * b[2, 2] + a[3, 3] * b[3, 2],
    //     a[3, 0] * b[0, 3] + a[3, 1] * b[1, 3] + a[3, 2] * b[2, 3] + a[3, 3] * b[3, 3],
    // };
}

matrix4_mul_tuple :: proc(a: Matrix4, b: $T/Tuple) -> T {
    return a * b;
    // return Tuple {
    //     a[0, 0] * b[0] + a[0, 1] * b[1] + a[0, 2] * b[2] + a[0, 3] * b[3],
    //     a[1, 0] * b[0] + a[1, 1] * b[1] + a[1, 2] * b[2] + a[1, 3] * b[3],
    //     a[2, 0] * b[0] + a[2, 1] * b[1] + a[2, 2] * b[2] + a[2, 3] * b[3],
    //     a[3, 0] * b[0] + a[3, 1] * b[1] + a[3, 2] * b[2] + a[3, 3] * b[3],
    // };
}

matrix4_transpose :: proc(a: Matrix4) -> Matrix4 {
    return transpose(a);
    /*return Matrix4 {*/
        /*a[0, 0], a[1, 0], a[2, 0], a[3, 0],*/
        /*a[0, 1], a[1, 1], a[2, 1], a[3, 1],*/
        /*a[0, 2], a[1, 2], a[2, 2], a[3, 2],*/
        /*a[0, 3], a[1, 3], a[2, 3], a[3, 3],*/
    /*};*/
}

matrix_transpose :: proc {
    matrix4_transpose,
}

// matrix2_determinant :: proc(a: Matrix2) -> real {
//     return a[0, 0] * a[1, 1] - a[0, 1] * a[1, 0];
// }

// matrix3_determinant :: proc(a: Matrix3) -> real {
//     return matrix_cofactor(a, 0, 0) * a[0, 0] +
//            matrix_cofactor(a, 0, 1) * a[0, 1] +
//            matrix_cofactor(a, 0, 2) * a[0, 2];
// }

// matrix4_determinant :: proc(a: Matrix4) -> real {
//     return matrix_cofactor(a, 0, 0) * a[0, 0] +
//            matrix_cofactor(a, 0, 1) * a[0, 1] +
//            matrix_cofactor(a, 0, 2) * a[0, 2] +
//            matrix_cofactor(a, 0, 3) * a[0, 3];
// }

// matrix_determinant :: proc {
//     matrix2_determinant,
//     matrix3_determinant,
//     matrix4_determinant,
// }

matrix_determinant :: #force_inline proc(m: $T/matrix[$R, $C]real) -> real {
    return determinant(m);
}

matrix3_submatrix :: proc(m: Matrix3, row, col: int) -> (result: Matrix2) {
    DIM :: 2;

    assert(row >= 0 && row <= DIM);
    assert(col >= 0 && col <= DIM);

    if (row == DIM && col == DIM) {
        return Matrix2(m);
    }

    dr, dc := 0, 0;

    for r in 0..=DIM {
        if r == row  do continue;
        for c in 0..=DIM {
            if c == col do continue;

            assert(dr < DIM);
            assert(dc < DIM);

            result[dr, dc] = m[r, c];

            dc += 1;
        }

        dc = 0;
        dr += 1;
    }

    return;
}

matrix4_submatrix :: proc(m: Matrix4, row, col: int) -> (result: Matrix3) {
    DIM :: 3;

    assert(row >= 0 && row <= DIM);
    assert(col >= 0 && col <= DIM);

    if (row == DIM && col == DIM) {
        return Matrix3(m);
    }

    dr, dc := 0, 0;

    for r in 0..=DIM {
        if r == row  do continue;
        for c in 0..=DIM {
            if c == col do continue;

            assert(dr < DIM);
            assert(dc < DIM);

            result[dr, dc] = m[r, c];

            dc += 1;
        }

        dc = 0;
        dr += 1;
    }

    return;
}

matrix_submatrix :: proc {
    matrix3_submatrix,
    matrix4_submatrix,
}

matrix_minor :: proc(m: $T/matrix[$R, $C]real, row, col: int) -> real {
    assert(row >= 0 && row < R);
    assert(col >= 0 && col < C);

    sub := matrix_submatrix(m, row, col);
    return matrix_determinant(sub);
}

matrix_cofactor :: proc(m: $T/matrix[$R, $C]real, row, col: int) -> real {
    assert(row >= 0 && row < R);
    assert(col >= 0 && col < C);

    minor := matrix_minor(m, row, col);

    if row + col % 2 == 0 do return minor;
    return -minor;
}

matrix_is_invertible :: proc(m: $T/matrix[$R, $C]real) -> bool {
    return matrix_determinant(m) != 0;
}

matrix_inverse :: proc(m: Matrix4) -> Matrix4 {

    return inverse(m);
    // determinant := matrix_determinant(m);
    // assert(determinant != 0);
    // // assert(matrix_is_invertible(m));

    // return Matrix4 {
    //      matrix_minor(m, 0, 0) / determinant,
    //     -matrix_minor(m, 1, 0) / determinant,
    //      matrix_minor(m, 2, 0) / determinant,
    //     -matrix_minor(m, 3, 0) / determinant,

    //     -matrix_minor(m, 0, 1) / determinant,
    //      matrix_minor(m, 1, 1) / determinant,
    //     -matrix_minor(m, 2, 1) / determinant,
    //      matrix_minor(m, 3, 1) / determinant,

    //      matrix_minor(m, 0, 2) / determinant,
    //     -matrix_minor(m, 1, 2) / determinant,
    //      matrix_minor(m, 2, 2) / determinant,
    //     -matrix_minor(m, 3, 2) / determinant,

    //     -matrix_minor(m, 0, 3) / determinant,
    //      matrix_minor(m, 1, 3) / determinant,
    //     -matrix_minor(m, 2, 3) / determinant,
    //      matrix_minor(m, 3, 3) / determinant,
    // };
}

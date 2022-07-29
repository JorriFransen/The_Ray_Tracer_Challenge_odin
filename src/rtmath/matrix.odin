package rtmath

import "core:reflect"
import "core:intrinsics"

@private
Matrix_Element_Type :: Tuple_Element_Type;

Matrix4 :: distinct matrix[4, 4]Matrix_Element_Type;
Matrix3 :: distinct matrix[3, 3]Matrix_Element_Type;
Matrix2 :: distinct matrix[2, 2]Matrix_Element_Type;

matrix4 :: proc(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33: Matrix_Element_Type) -> Matrix4 {
    return Matrix4 { m00, m01, m02, m03,
                     m10, m11, m12, m13,
                     m20, m21, m22, m23,
                     m30, m31, m32, m33 };
}

matrix3 :: proc(m00, m01, m02, m10, m11, m12, m20, m21, m22: Matrix_Element_Type) -> Matrix3 {
    return Matrix3 { m00, m01, m02,
                     m10, m11, m12,
                     m20, m21, m22 };
}

matrix2 :: proc(m00, m01, m10, m11: Matrix_Element_Type) -> Matrix2 {
    return Matrix2 { m00, m01,
                     m10, m11 };
}

matrix4_eq :: proc(a, b: Matrix4) -> bool {
    Flat_Type :: [16]Matrix_Element_Type;

    a_flat := transmute(Flat_Type)a;
    b_flat := transmute(Flat_Type)b;

    return eq(a_flat, b_flat);
}

matrix3_eq :: proc(a, b: Matrix3) -> bool {
    Flat_Type :: [9]Matrix_Element_Type;

    a_flat := transmute(Flat_Type)a;
    b_flat := transmute(Flat_Type)b;

    return eq(a_flat, b_flat);
}

matrix2_eq :: proc(a, b: Matrix2) -> bool {
    Flat_Type :: [4]Matrix_Element_Type;

    a_flat := transmute(Flat_Type)a;
    b_flat := transmute(Flat_Type)b;

    return eq(a_flat, b_flat);
}

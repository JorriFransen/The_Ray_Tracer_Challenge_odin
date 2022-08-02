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
        test("Rot_Around_X", Rot_Around_X),
        test("Rot_Around_X_Inv", Rot_Around_X_Inv),
        test("Rot_Around_Y", Rot_Around_Y),
        test("Rot_Around_Y_Inv", Rot_Around_Y_Inv),
        test("Rot_Around_Z", Rot_Around_Z),
        test("Rot_Around_Z_Inv", Rot_Around_Z_Inv),
        test("Shear_XY", Shear_XY),
        test("Shear_XZ", Shear_XZ),
        test("Shear_YX", Shear_YX),
        test("Shear_YZ", Shear_YZ),
        test("Shear_ZX", Shear_ZX),
        test("Shear_ZY", Shear_ZY),
        test("Sequenced", Sequenced),
        test("Chained", Chained),
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

    expect(t, rm.translate(p, 5, -3, 2) == expected);
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

    {
        inv := rm.matrix_inverse(rm.translate(rm.matrix4_identity, 5, -3, 2));
        result := inv * p;
        expect(t, result == expected);
    }
}

@test
V_Mul_Translation :: proc(t: ^testing.T) {

    transform := rm.translation(5, -3, 2);
    v := rm.vector(-3, 4, 5);

    result1 := rm.mul(transform, v);
    result2 := transform * v;

    expect(t, result1 == v);
    expect(t, result2 == v);

    expect(t, rm.translate(v, 5, -3, 2) == v);
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

    expect(t, rm.scale(p, 2, 3, 4) == expected);
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

    expect(t, rm.scale(v, 2, 3, 4) == expected);
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

    expect(t, rm.scale(v, 1.0 / 2, 1.0 / 3, 1.0 / 4) == expected);

    {
        inv := rm.matrix_inverse(rm.scale(rm.matrix4_identity, 2, 3, 4));
        result := inv * v;
        expect(t, result == expected);
    }
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

    expect(t, rm.scale(p, -1, 1, 1) == expected);
}

@test
Rot_Around_X :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_x(PI / 4);
    full_quarter := rm.rotation_x(PI / 2);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected1 := rm.point(0, sqrt2_d2, sqrt2_d2);
    expected2 := rm.point(0, 0, 1);

    half_result_1 := rm.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := rm.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    expect(t, rm.eq(half_result_1, expected1));
    expect(t, rm.eq(half_result_2, expected1));
    expect(t, rm.eq(rm.rotate_x(p, PI / 4), expected1));

    expect(t, rm.eq(full_result_1, expected2));
    expect(t, rm.eq(full_result_2, expected2));
    expect(t, rm.eq(rm.rotate_x(p, PI / 2), expected2));
}

@test
Rot_Around_X_Inv :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_x(PI / 4);
    inv := rm.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected := rm.point(0, sqrt2_d2, -sqrt2_d2);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.rotate_x(p, -PI / 4), expected));

    {
        inv := rm.matrix_inverse(rm.rotate_x(rm.matrix4_identity, PI / 4));
        expect(t, rm.eq(rm.mul(inv, p), expected));
    }
}

@test
Rot_Around_Y :: proc(t: ^testing.T) {

    p := rm.point(0, 0, 1);
    half_quarter := rm.rotation_y(PI / 4);
    full_quarter := rm.rotation_y(PI / 2);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected1 := rm.point(sqrt2_d2, 0, sqrt2_d2);
    expected2 := rm.point(1, 0, 0);

    half_result_1 := rm.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := rm.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    expect(t, rm.eq(half_result_1, expected1));
    expect(t, rm.eq(half_result_2, expected1));
    expect(t, rm.eq(rm.rotate_y(p, PI / 4), expected1));

    expect(t, rm.eq(full_result_1, expected2));
    expect(t, rm.eq(full_result_2, expected2));
    expect(t, rm.eq(rm.rotate_y(p, PI / 2), expected2));
}

@test
Rot_Around_Y_Inv :: proc(t: ^testing.T) {

    p := rm.point(0, 0, 1);
    half_quarter := rm.rotation_y(PI / 4);
    inv := rm.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected := rm.point(-sqrt2_d2, 0, sqrt2_d2);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.rotate_y(p, -PI / 4), expected));

    {
        inv := rm.matrix_inverse(rm.rotate_y(rm.matrix4_identity, PI / 4));
        expect(t, rm.eq(rm.mul(inv, p), expected));
    }
}

@test
Rot_Around_Z :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_z(PI / 4);
    full_quarter := rm.rotation_z(PI / 2);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected1 := rm.point(-sqrt2_d2, sqrt2_d2, 0);
    expected2 := rm.point(-1, 0, 0);

    half_result_1 := rm.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := rm.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    expect(t, rm.eq(half_result_1, expected1));
    expect(t, rm.eq(half_result_2, expected1));
    expect(t, rm.eq(rm.rotate_z(p, PI / 4), expected1));

    expect(t, rm.eq(full_result_1, expected2));
    expect(t, rm.eq(full_result_2, expected2));
    expect(t, rm.eq(rm.rotate_z(p, PI / 2), expected2));
}

@test
Rot_Around_Z_Inv :: proc(t: ^testing.T) {

    p := rm.point(0, 1, 0);
    half_quarter := rm.rotation_z(math.PI / 4);
    inv := rm.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(rm.Tuple_Element_Type(2)) / 2.0;
    expected := rm.point(sqrt2_d2, sqrt2_d2, 0);

    result1 := rm.mul(inv, p);
    result2 := inv * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.rotate_z(p, -PI / 4), expected));

    {
        inv := rm.matrix_inverse(rm.rotate_z(rm.matrix4_identity, PI / 4));
        expect(t, rm.eq(rm.mul(inv, p), expected));
    }
}

@test
Shear_XY :: proc(t: ^testing.T) {

    transform := rm.shearing(1, 0, 0, 0, 0, 0);
    p := rm.point(2, 3, 4);

    expected := rm.point(5, 3, 4);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.shear(p, 1, 0, 0, 0, 0, 0), expected));
}


@test
Shear_XZ :: proc(t: ^testing.T) {

    transform := rm.shearing(0, 1, 0, 0, 0, 0);
    p := rm.point(2, 3, 4);

    expected := rm.point(6, 3, 4);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.shear(p, 0, 1, 0, 0, 0, 0), expected));
}

@test
Shear_YX :: proc(t: ^testing.T) {

    transform := rm.shearing(0, 0, 1, 0, 0, 0);
    p := rm.point(2, 3, 4);

    expected := rm.point(2, 5, 4);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.shear(p, 0, 0, 1, 0, 0, 0), expected));
}

@test
Shear_YZ :: proc(t: ^testing.T) {

    transform := rm.shearing(0, 0, 0, 1, 0, 0);
    p := rm.point(2, 3, 4);

    expected := rm.point(2, 7, 4);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.shear(p, 0, 0, 0, 1, 0, 0), expected));
}

@test
Shear_ZX :: proc(t: ^testing.T) {

    transform := rm.shearing(0, 0, 0, 0, 1, 0);
    p := rm.point(2, 3, 4);

    expected := rm.point(2, 3, 6);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.shear(p, 0, 0, 0, 0, 1, 0), expected));
}

@test
Shear_ZY :: proc(t: ^testing.T) {

    transform := rm.shearing(0, 0, 0, 0, 0, 1);
    p := rm.point(2, 3, 4);

    expected := rm.point(2, 3, 7);

    result1 := rm.mul(transform, p);
    result2 := transform * p;

    expect(t, rm.eq(result1, expected));
    expect(t, rm.eq(result2, expected));
    expect(t, rm.eq(rm.shear(p, 0, 0, 0, 0, 0, 1), expected));
}

@test
Sequenced :: proc(t: ^testing.T) {

    p := rm.point(1, 0, 1);
    A := rm.rotation_x(PI / 2);
    B := rm.scaling(5, 5, 5);
    C := rm.translation(10, 5, 7);

    {
        p2 := rm.mul(A, p);
        expect(t, rm.eq(p2, rm.point(1, -1, 0)))

        p3 := rm.mul(B, p2);
        expect(t, rm.eq(p3, rm.point(5, -5, 0)));

        p4 := rm.mul(C, p3);
        expect(t, rm.eq(p4, rm.point(15, 0, 7)));
    }

    {
        p2 := A * p;
        expect(t, rm.eq(p2, rm.point(1, -1, 0)))

        p3 := B * p2;
        expect(t, rm.eq(p3, rm.point(5, -5, 0)));

        p4 := C * p3;
        expect(t, rm.eq(p4, rm.point(15, 0, 7)));
    }

    {
        p2 := rm.rotate_x(p, PI / 2);
        expect(t, rm.eq(p2, rm.point(1, -1, 0)))

        p3 := rm.scale(p2, 5, 5, 5);
        expect(t, rm.eq(p3, rm.point(5, -5, 0)));

        p4 := rm.translate(p3, 10, 5, 7);
        expect(t, rm.eq(p4, rm.point(15, 0, 7)));
    }
}

@test
Chained :: proc(t: ^testing.T) {

    p := rm.point(1, 0, 1);
    A := rm.rotation_x(PI / 2);
    B := rm.scaling(5, 5, 5);
    C := rm.translation(10, 5, 7);

    T : rm.Matrix4;
    expected := rm.point(15, 0, 7);

    {
        T1 := rm.mul(C, rm.mul(B, A));
        T2 := C * B * A;

        expect(t, rm.eq(T1, T2));
        T = T1;

        result1 := rm.mul(T1, p);
        result11 := T1 * p;

        result2 := rm.mul(T2, p);
        result22 := T2 * p;

        expect(t, rm.eq(result1, expected));
        expect(t, rm.eq(result11, expected))

        expect(t, rm.eq(result2, expected));
        expect(t, rm.eq(result22, expected))
    }

    {
        T1 := rm.translate(rm.scale(rm.rotation_x(PI / 2), 5, 5, 5), 10, 5, 7);

        expect(t, rm.eq(T, T1));

        result := rm.mul(T1, p);

        expect(t, rm.eq(result, expected));
    }

    {
        T1 := rm.translate(rm.scale(rm.rotate_x(rm.matrix4_identity, PI / 2), 5, 5, 5), 10, 5, 7);

        expect(t, rm.eq(T, T1));

        result := rm.mul(T1, p);

        expect(t, rm.eq(result, expected));
    }

    {
        result := rm.translate(rm.scale(rm.rotate_x(p, PI / 2), 5, 5, 5), 10, 5, 7);

        expect(t, rm.eq(result, expected));
    }
}

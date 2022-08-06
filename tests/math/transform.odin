package tests_math

import "core:testing"
import "core:math"

import m "raytracer:math"

import r "../runner"

PI :: math.PI;
sqrt :: math.sqrt;

transform_suite := r.Test_Suite {
    name = "Tfm/",
    tests = {
        r.test("P_Mul_Translation", P_Mul_Translation),
        r.test("P_Mul_Inv_Translation", P_Mul_Inv_Translation),
        r.test("V_Mul_Translation", V_Mul_Translation),
        r.test("P_Mul_Scale", P_Mul_Scale),
        r.test("V_Mul_Scale", V_Mul_Scale),
        r.test("V_Mul_Inv_Scale", V_Mul_Inv_Scale),
        r.test("Reflection_Is_Neg_Scale", Reflection_Is_Neg_Scale),
        r.test("Rot_Around_X", Rot_Around_X),
        r.test("Rot_Around_X_Inv", Rot_Around_X_Inv),
        r.test("Rot_Around_Y", Rot_Around_Y),
        r.test("Rot_Around_Y_Inv", Rot_Around_Y_Inv),
        r.test("Rot_Around_Z", Rot_Around_Z),
        r.test("Rot_Around_Z_Inv", Rot_Around_Z_Inv),
        r.test("Shear_XY", Shear_XY),
        r.test("Shear_XZ", Shear_XZ),
        r.test("Shear_YX", Shear_YX),
        r.test("Shear_YZ", Shear_YZ),
        r.test("Shear_ZX", Shear_ZX),
        r.test("Shear_ZY", Shear_ZY),
        r.test("Sequenced", Sequenced),
        r.test("Chained", Chained),
        r.test("View_Default", View_Default),
        r.test("View_Positive_Z", View_Positive_Z),
        r.test("View_Moves_World", View_Moves_World),
        r.test("View_Arbitrary", View_Arbitrary),
    },
};

@test
P_Mul_Translation :: proc(t: ^r.T) {

    transform := m.translation(5, -3, 2);
    p := m.point(-3, 4, 5);

    expected := m.point(2, 1, 7);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, result1 == expected);
    r.expect(t, result2 == expected);

    r.expect(t, m.translate(p, 5, -3, 2) == expected);
}

@test
P_Mul_Inv_Translation :: proc(t: ^r.T) {

    transform := m.translation(5, -3, 2);
    inv := m.matrix_inverse(transform);
    p := m.point(-3, 4, 5);

    expected := m.point(-8, 7, 3);

    result1 := m.mul(inv, p);
    result2 := inv * p;

    r.expect(t, result1 == expected);
    r.expect(t, result2 == expected);

    {
        inv := m.matrix_inverse(m.translate(m.matrix4_identity, 5, -3, 2));
        result := inv * p;
        r.expect(t, result == expected);
    }
}

@test
V_Mul_Translation :: proc(t: ^r.T) {

    transform := m.translation(5, -3, 2);
    v := m.vector(-3, 4, 5);

    result1 := m.mul(transform, v);
    result2 := transform * v;

    r.expect(t, result1 == v);
    r.expect(t, result2 == v);

    r.expect(t, m.translate(v, 5, -3, 2) == v);
}

@test
P_Mul_Scale :: proc(t: ^r.T) {

    transform := m.scaling(2, 3, 4);
    p := m.point(-4, 6, 8);

    expected := m.point(-8, 18, 32);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, result1 == expected);
    r.expect(t, result2 == expected);

    r.expect(t, m.scale(p, 2, 3, 4) == expected);
}

@test
V_Mul_Scale :: proc(t: ^r.T) {

    transform := m.scaling(2, 3, 4);
    v := m.vector(-4, 6, 8);

    expected := m.vector(-8, 18, 32);

    result1 := m.mul(transform, v);
    result2 := transform * v;

    r.expect(t, result1 == expected);
    r.expect(t, result2 == expected);

    r.expect(t, m.scale(v, 2, 3, 4) == expected);
}

@test
V_Mul_Inv_Scale :: proc(t: ^r.T) {

    transform := m.scaling(2, 3, 4);
    inv := m.matrix_inverse(transform);
    v := m.vector(-4, 6, 8);

    expected := m.vector(-2, 2, 2);

    result1 := m.mul(inv, v);
    result2 := inv * v;

    r.expect(t, result1 == expected);
    r.expect(t, result2 == expected);

    r.expect(t, m.scale(v, 1.0 / 2, 1.0 / 3, 1.0 / 4) == expected);

    {
        inv := m.matrix_inverse(m.scale(m.matrix4_identity, 2, 3, 4));
        result := inv * v;
        r.expect(t, result == expected);
    }
}

@test
Reflection_Is_Neg_Scale :: proc(t: ^r.T) {

    transform := m.scaling(-1, 1, 1);
    p := m.point(2, 3, 4);

    expected := m.point(-2, 3, 4);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, result1 == expected);
    r.expect(t, result2 == expected);

    r.expect(t, m.scale(p, -1, 1, 1) == expected);
}

@test
Rot_Around_X :: proc(t: ^r.T) {

    p := m.point(0, 1, 0);
    half_quarter := m.rotation_x(PI / 4);
    full_quarter := m.rotation_x(PI / 2);

    sqrt2_d2 := sqrt(m.real(2)) / 2.0;
    expected1 := m.point(0, sqrt2_d2, sqrt2_d2);
    expected2 := m.point(0, 0, 1);

    half_result_1 := m.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := m.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    r.expect(t, m.eq(half_result_1, expected1));
    r.expect(t, m.eq(half_result_2, expected1));
    r.expect(t, m.eq(m.rotate_x(p, PI / 4), expected1));

    r.expect(t, m.eq(full_result_1, expected2));
    r.expect(t, m.eq(full_result_2, expected2));
    r.expect(t, m.eq(m.rotate_x(p, PI / 2), expected2));
}

@test
Rot_Around_X_Inv :: proc(t: ^r.T) {

    p := m.point(0, 1, 0);
    half_quarter := m.rotation_x(PI / 4);
    inv := m.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(m.real(2)) / 2.0;
    expected := m.point(0, sqrt2_d2, -sqrt2_d2);

    result1 := m.mul(inv, p);
    result2 := inv * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.rotate_x(p, -PI / 4), expected));

    {
        inv := m.matrix_inverse(m.rotate_x(m.matrix4_identity, PI / 4));
        r.expect(t, m.eq(m.mul(inv, p), expected));
    }
}

@test
Rot_Around_Y :: proc(t: ^r.T) {

    p := m.point(0, 0, 1);
    half_quarter := m.rotation_y(PI / 4);
    full_quarter := m.rotation_y(PI / 2);

    sqrt2_d2 := sqrt(m.real(2)) / 2.0;
    expected1 := m.point(sqrt2_d2, 0, sqrt2_d2);
    expected2 := m.point(1, 0, 0);

    half_result_1 := m.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := m.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    r.expect(t, m.eq(half_result_1, expected1));
    r.expect(t, m.eq(half_result_2, expected1));
    r.expect(t, m.eq(m.rotate_y(p, PI / 4), expected1));

    r.expect(t, m.eq(full_result_1, expected2));
    r.expect(t, m.eq(full_result_2, expected2));
    r.expect(t, m.eq(m.rotate_y(p, PI / 2), expected2));
}

@test
Rot_Around_Y_Inv :: proc(t: ^r.T) {

    p := m.point(0, 0, 1);
    half_quarter := m.rotation_y(PI / 4);
    inv := m.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(m.real(2)) / 2.0;
    expected := m.point(-sqrt2_d2, 0, sqrt2_d2);

    result1 := m.mul(inv, p);
    result2 := inv * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.rotate_y(p, -PI / 4), expected));

    {
        inv := m.matrix_inverse(m.rotate_y(m.matrix4_identity, PI / 4));
        r.expect(t, m.eq(m.mul(inv, p), expected));
    }
}

@test
Rot_Around_Z :: proc(t: ^r.T) {

    p := m.point(0, 1, 0);
    half_quarter := m.rotation_z(PI / 4);
    full_quarter := m.rotation_z(PI / 2);

    sqrt2_d2 := sqrt(m.real(2)) / 2.0;
    expected1 := m.point(-sqrt2_d2, sqrt2_d2, 0);
    expected2 := m.point(-1, 0, 0);

    half_result_1 := m.mul(half_quarter, p);
    half_result_2 := half_quarter * p;

    full_result_1 := m.mul(full_quarter, p);
    full_result_2 := full_quarter * p;

    r.expect(t, m.eq(half_result_1, expected1));
    r.expect(t, m.eq(half_result_2, expected1));
    r.expect(t, m.eq(m.rotate_z(p, PI / 4), expected1));

    r.expect(t, m.eq(full_result_1, expected2));
    r.expect(t, m.eq(full_result_2, expected2));
    r.expect(t, m.eq(m.rotate_z(p, PI / 2), expected2));
}

@test
Rot_Around_Z_Inv :: proc(t: ^r.T) {

    p := m.point(0, 1, 0);
    half_quarter := m.rotation_z(math.PI / 4);
    inv := m.matrix_inverse(half_quarter);

    sqrt2_d2 := sqrt(m.real(2)) / 2.0;
    expected := m.point(sqrt2_d2, sqrt2_d2, 0);

    result1 := m.mul(inv, p);
    result2 := inv * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.rotate_z(p, -PI / 4), expected));

    {
        inv := m.matrix_inverse(m.rotate_z(m.matrix4_identity, PI / 4));
        r.expect(t, m.eq(m.mul(inv, p), expected));
    }
}

@test
Shear_XY :: proc(t: ^r.T) {

    transform := m.shearing(1, 0, 0, 0, 0, 0);
    p := m.point(2, 3, 4);

    expected := m.point(5, 3, 4);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.shear(p, 1, 0, 0, 0, 0, 0), expected));
}


@test
Shear_XZ :: proc(t: ^r.T) {

    transform := m.shearing(0, 1, 0, 0, 0, 0);
    p := m.point(2, 3, 4);

    expected := m.point(6, 3, 4);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.shear(p, 0, 1, 0, 0, 0, 0), expected));
}

@test
Shear_YX :: proc(t: ^r.T) {

    transform := m.shearing(0, 0, 1, 0, 0, 0);
    p := m.point(2, 3, 4);

    expected := m.point(2, 5, 4);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.shear(p, 0, 0, 1, 0, 0, 0), expected));
}

@test
Shear_YZ :: proc(t: ^r.T) {

    transform := m.shearing(0, 0, 0, 1, 0, 0);
    p := m.point(2, 3, 4);

    expected := m.point(2, 7, 4);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.shear(p, 0, 0, 0, 1, 0, 0), expected));
}

@test
Shear_ZX :: proc(t: ^r.T) {

    transform := m.shearing(0, 0, 0, 0, 1, 0);
    p := m.point(2, 3, 4);

    expected := m.point(2, 3, 6);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.shear(p, 0, 0, 0, 0, 1, 0), expected));
}

@test
Shear_ZY :: proc(t: ^r.T) {

    transform := m.shearing(0, 0, 0, 0, 0, 1);
    p := m.point(2, 3, 4);

    expected := m.point(2, 3, 7);

    result1 := m.mul(transform, p);
    result2 := transform * p;

    r.expect(t, m.eq(result1, expected));
    r.expect(t, m.eq(result2, expected));
    r.expect(t, m.eq(m.shear(p, 0, 0, 0, 0, 0, 1), expected));
}

@test
Sequenced :: proc(t: ^r.T) {

    p := m.point(1, 0, 1);
    A := m.rotation_x(PI / 2);
    B := m.scaling(5, 5, 5);
    C := m.translation(10, 5, 7);

    {
        p2 := m.mul(A, p);
        r.expect(t, m.eq(p2, m.point(1, -1, 0)))

        p3 := m.mul(B, p2);
        r.expect(t, m.eq(p3, m.point(5, -5, 0)));

        p4 := m.mul(C, p3);
        r.expect(t, m.eq(p4, m.point(15, 0, 7)));
    }

    {
        p2 := A * p;
        r.expect(t, m.eq(p2, m.point(1, -1, 0)))

        p3 := B * p2;
        r.expect(t, m.eq(p3, m.point(5, -5, 0)));

        p4 := C * p3;
        r.expect(t, m.eq(p4, m.point(15, 0, 7)));
    }

    {
        p2 := m.rotate_x(p, PI / 2);
        r.expect(t, m.eq(p2, m.point(1, -1, 0)))

        p3 := m.scale(p2, 5, 5, 5);
        r.expect(t, m.eq(p3, m.point(5, -5, 0)));

        p4 := m.translate(p3, 10, 5, 7);
        r.expect(t, m.eq(p4, m.point(15, 0, 7)));
    }
}

@test
Chained :: proc(t: ^r.T) {

    p := m.point(1, 0, 1);
    A := m.rotation_x(PI / 2);
    B := m.scaling(5, 5, 5);
    C := m.translation(10, 5, 7);

    T : m.Matrix4;
    expected := m.point(15, 0, 7);

    {
        T1 := m.mul(C, m.mul(B, A));
        T2 := C * B * A;

        r.expect(t, m.eq(T1, T2));
        T = T1;

        result1 := m.mul(T1, p);
        result11 := T1 * p;

        result2 := m.mul(T2, p);
        result22 := T2 * p;

        r.expect(t, m.eq(result1, expected));
        r.expect(t, m.eq(result11, expected))

        r.expect(t, m.eq(result2, expected));
        r.expect(t, m.eq(result22, expected))
    }

    {
        T1 := m.translate(m.scale(m.rotation_x(PI / 2), 5, 5, 5), 10, 5, 7);

        r.expect(t, m.eq(T, T1));

        result := m.mul(T1, p);

        r.expect(t, m.eq(result, expected));
    }

    {
        T1 := m.translate(m.scale(m.rotate_x(m.matrix4_identity, PI / 2), 5, 5, 5), 10, 5, 7);

        r.expect(t, m.eq(T, T1));

        result := m.mul(T1, p);

        r.expect(t, m.eq(result, expected));
    }

    {
        result := m.translate(m.scale(m.rotate_x(p, PI / 2), 5, 5, 5), 10, 5, 7);

        r.expect(t, m.eq(result, expected));
    }
}

@test
View_Default :: proc(t: ^r.T) {

    from := m.point(0, 0, 0);
    to := m.point(0, 0, -1);
    up := m.vector(0, 1, 0);


    tf := m.view_transform(from, to, up);

    r.expect(t, m.eq(tf, m.matrix4_identity));
}

@test
View_Positive_Z :: proc(t: ^r.T) {

    from := m.point(0, 0, 0);
    to := m.point(0, 0, 1);
    up := m.vector(0, 1, 0);

    tf := m.view_transform(from, to, up);

    r.expect(t, m.eq(tf, m.scaling(-1, 1, -1)));
}

@test
View_Moves_World :: proc(t: ^r.T) {

    from := m.point(0, 0, 8);
    to := m.point(0, 0, 0);
    up := m.vector(0, 1, 0);

    tf := m.view_transform(from, to, up);

    r.expect(t, m.eq(tf, m.translation(0, 0, -8)));
}

@test
View_Arbitrary :: proc(t: ^r.T) {

    from := m.point(1, 3, 2);
    to := m.point(4, -2, 8);
    up := m.vector(1, 1, 0);

    tf := m.view_transform(from, to, up);

    expected := m.matrix4(
        -0.50709, 0.50709,  0.67612, -2.36643,
         0.76772, 0.60609,  0.12122, -2.82843,
        -0.35857, 0.59761, -0.71714,  0.00000,
         0.00000, 0.00000,  0.00000,  1.00000,
    );

    r.expect(t, m.eq(tf, expected));
}

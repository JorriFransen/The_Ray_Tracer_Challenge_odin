package tests

import "core:fmt"
import "core:testing"
import cm "core:math"

import m "../src/rtmath"

@test
Tuple_Is_Point :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.Tuple { 4.3, -4.2, 3.1, 1.0 };

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

    a := m.Tuple { 4.3, -4.2, 3.1, 0.0 };

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

    expected := m.Tuple { 4, -4, 3, 1 };

    expect(t, m.is_point(p));
    expect(t, m.Tuple(p) == expected);
}

@test
Vector_Constructor :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(4, -4, 3);

    expected := m.Tuple { 4, -4, 3, 0 };

    expect(t, m.is_vector(v));
    expect(t, m.Tuple(v) == expected);
}

@test
Tuple_Add :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a1 := m.Tuple { 3, -2, 5, 1 };
    a2 := m.Tuple { -2, 3, 1, 0 };

    expected := m.Tuple { 1, 1, 6, 1 };

    expect(t, m.add(a1, a2) == expected);
}

@test
Add_Point_And_Vector :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    p := m.point(3, -2, 5);
    v := m.vector(-2, 3, 1);

    expected := m.point(1, 1, 6);
    result := m.add(p, v);

    expect(t, result == expected);
    expect(t, m.is_point(result));
}

@test
Add_Vector_And_Point :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(3, -2, 5);
    p := m.point(-2, 3, 1);

    expected := m.point(1, 1, 6);
    result := m.add(v, p);

    expect(t, result == expected);
    expect(t, m.is_point(result));
}

@test
Vector_Add :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v1 := m.vector(3, -2, 5);
    v2 := m.vector(-2, 3, 1);

    expected := m.vector(1, 1, 6);
    result := m.add(v1, v2);

    expect(t, result == expected);
    expect(t, m.is_vector(result));
}

@test
Tuple_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.Tuple { 3, 2, 1, 1 };
    b := m.Tuple { 5, 6, 7, 1 };

    expected := m.Tuple { -2, -4, -6, 0 };
    result := m.sub(a, b);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
}

@test
Point_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.point(3, 2, 1);
    b := m.point(5, 6, 7);

    expected := m.vector(-2, -4, -6);
    result := m.sub(a, b);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
}

@test
Point_Sub_Vector :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    p := m.point(3, 2, 1);
    v := m.vector(5, 6, 7);

    expected := m.point(-2, -4, -6);
    result := m.sub(p, v);

    expect(t, m.is_point(result));
    expect(t, result == expected);
}

@test
Vector_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v1 := m.vector(3, 2, 1);
    v2 := m.vector(5, 6, 7);

    expected := m.vector(-2, -4, -6);
    result  := m.sub(v1, v2);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
}


@test
Vector_Sub_From_Zero :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    zero := m.vector(0, 0, 0);
    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result := m.sub(zero, v);

    expect(t, m.is_vector(result));
    expect(t, result == expected);
}

@test
Tuple_Negate :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.Tuple { 1, -2, 3, -4 };

    expected := m.Tuple { -1, 2, -3, 4 };
    result := m.negate(a);

    expect(t, result == expected);
}

@test
Vector_Negate :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, -2, 3);

    expected := m.vector(-1, 2, -3);
    result := m.negate(v);

    expect(t, m.is_vector(result));
    expect(t, m.eq(result, expected));
}

@test
Tuple_Mul_Scalar :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.Tuple { 1, -2, 3, -4 };

    expected := m.Tuple { 3.5, -7, 10.5, -14 };
    result := m.mul(a, 3.5);

    expect(t, result == expected);
}

@test
Tuple_Mul_Fraction :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.Tuple { 1, -2, 3, -4 };

    expected := m.Tuple { 0.5, -1, 1.5, -2 };
    result := m.mul(a, 0.5);

    expect(t, result == expected);
}

@test
Tuple_Div_Scalar :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.Tuple { 1, -2, 3, -4 };

    expected := m.Tuple { 0.5, -1, 1.5, -2 };
    result := m.div(a, 2);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, 0, 0);

    expected : f32 = 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_Y1 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(0, 1, 0);

    expected : f32 = 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_Z1 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(0, 0, 1);

    expected : f32 = 1.0;
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1_Y2_Z3 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, 2, 3);

    expected := cm.sqrt(f32(14));
    result := m.magnitude(v);

    expect(t, result == expected);
}

@test
Vector_Magnitude_X1_Y2_Z3_Neg :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(-1, -2, -3);

    expected := cm.sqrt(f32(14));
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
}

@test
Vector_Normalize_X1_Y2_Z3 :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    v := m.vector(1, 2, 3);

    // 1*1 + 2*2 + 3*3 = 14
    /*expected := m.vector(1 / cm.sqrt(f32(14)), 2 / cm.sqrt(f32(14)), 3 / cm.sqrt(f32(14)));*/
    expected := m.vector(0.26726, 0.53452, 0.80178);
    result := m.normalize(v);

    expect(t, m.eq(result, expected));
}

@test
Vector_Dot :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    a := m.vector(1, 2, 3);
    b := m.vector(2, 3, 4);

    expected : f32 = 20.0;
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
    expect(t, result_ba == expected_ba);
}

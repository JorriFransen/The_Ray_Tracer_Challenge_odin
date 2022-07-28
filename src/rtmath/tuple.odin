package rtmath

import "core:fmt"
import "core:intrinsics"
import "core:simd"
import cm "core:math"

Tuple :: distinct [4]f32;
Point :: distinct Tuple;
Vector :: distinct Tuple;

tuple :: proc(x, y, z, w: intrinsics.type_field_type(Tuple, "x")) -> Tuple {
    return Tuple { x, y, z, w };
}

point :: proc(x, y, z: intrinsics.type_field_type(Tuple, "x")) -> Point {
    return Point { x, y, z, 1.0 };
}

vector :: proc(x, y, z: intrinsics.type_field_type(Tuple, "x")) -> Vector {
    return Vector { x, y, z, 0.0 };
}

is_point :: proc(t: $T/Tuple) -> bool {
    return t.w == 1.0;
}

is_vector :: proc(t: $T/Tuple) -> bool {
    return t.w == 0.0;
}

eq_internal :: proc(a, b: $T/[4]$E) -> bool {
    simd_diff := simd.abs(simd.from_array(a) - simd.from_array(b));
    simd_epsilon : #simd[4]E : { FLOAT_EPSILON, FLOAT_EPSILON, FLOAT_EPSILON, FLOAT_EPSILON };

    simd_neq := simd.lanes_ge(simd_diff, simd_epsilon);
    res := simd.reduce_max(simd_neq);
    return res == 0;
}

eq_pt :: #force_inline proc(a: Point, b: Tuple) -> bool {
    return eq_internal(Tuple(a), b);
}

eq_vt :: #force_inline proc(a: Vector, b: Tuple) -> bool {
    return eq_internal(Tuple(a), b);
}

eq :: proc { eq_internal, eq_pt, eq_vt };

add_t :: #force_inline proc(a, b: Tuple) -> Tuple {
    return a + b;
}

add_v :: #force_inline proc(a, b: Vector) -> Vector {
    return a + b;
}

add_pv :: #force_inline proc(a: Point, b: Vector) -> Point {
    assert(is_point(a));
    assert(is_vector(b));

    result := a + Point(b);

    assert(is_point(result));

    return result;
}

add_vp :: #force_inline proc(a: Vector, b: Point) -> Point {
    return add_pv(b, a);
}

add :: proc { add_t, add_v, add_pv, add_vp };

sub_t :: #force_inline proc(a, b: Tuple) -> Tuple  {
    return a - b;
}

sub_p :: #force_inline proc(a, b: Point) -> Vector {
    assert(is_point(a));
    assert(is_point(b));

    result := Vector(a - b);

    assert(is_vector(result));

    return result;
}

sub_v :: #force_inline proc(a, b: Vector) -> Vector {
    return a - b;
}

sub_pv :: #force_inline proc(a: Point, b: Vector) -> Point {
    assert(is_point(a));
    assert(is_vector(b));

    result := Point(a - Point(b));

    assert(is_point(result));

    return result;
}

sub :: proc { sub_t, sub_p, sub_v, sub_pv };

negate_t :: #force_inline proc(t: Tuple) -> Tuple {
    return -t;
}

negate_v :: #force_inline proc(t: Vector) -> Vector {
    return -t;
}

negate :: proc { negate_t, negate_v };

mul_t :: #force_inline proc(t: Tuple, s: intrinsics.type_field_type(Tuple, "x")) -> Tuple {
    return t * s;
}

mul :: proc { mul_t };

div_t :: #force_inline proc(t: Tuple, s: intrinsics.type_field_type(Tuple, "x")) -> Tuple {
    return t / s;
}

div :: proc { div_t };

magnitude :: proc(v: Vector) -> intrinsics.type_field_type(Vector, "x") {

    sum := simd.reduce_add_ordered(simd.from_array(v * v));
    return cm.sqrt(sum);

    /*return cm.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);*/
}

normalize :: proc(v: Vector) -> Vector {
    m := magnitude(v);
    return v / m;
}

dot :: proc(a, b: Vector) -> intrinsics.type_field_type(Vector, "x") {
    return simd.reduce_add_ordered(simd.from_array(a * b));
}

cross :: proc(a, b: Vector) -> Vector {
    return a.yzxw * b.zxyw - a.zxyw * b.yzxw;
}

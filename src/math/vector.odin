package rtmath

import "core:fmt"
import "core:intrinsics"
import "core:simd"
import cm "core:math"

real :: f32;

Tuple :: distinct [4]real;
Point :: distinct Tuple;
Vector :: distinct Tuple;

tuple :: proc(x, y, z, w: real) -> Tuple {
    return Tuple { x, y, z, w };
}

point_xyz :: proc(x, y, z: real) -> Point {
    return Point { x, y, z, 1.0 };
}

point_t :: proc(t: Tuple) -> Point {
    return Point { t.x, t.y, t.z, 1.0 };
}

point :: proc {
    point_xyz,
    point_t,
}

vector_xyz :: proc(x, y, z: real) -> Vector {
    return Vector { x, y, z, 0.0 };
}

vector_t :: proc(t: Tuple) -> Vector {
    return Vector { t.x, t.y, t.z, 0.0 };
}

vector :: proc {
    vector_xyz,
    vector_t,
}

is_point :: proc(t: $T/Tuple) -> bool {
    return t.w == 1.0;
}

is_vector :: proc(t: $T/Tuple) -> bool {
    return t.w == 0.0;
}

tuple_eq :: proc(a_, b_: $T/[4]real) -> bool {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    simd_diff := simd.abs(simd.from_array(a - b));
    simd_epsilon : #simd[4]real : { FLOAT_EPSILON, FLOAT_EPSILON, FLOAT_EPSILON, FLOAT_EPSILON };

    simd_neq := simd.lanes_ge(simd_diff, simd_epsilon);
    res := simd.reduce_max(simd_neq);
    return res == 0;
}

tuple_eq_pt :: #force_inline proc(a: Point, b: Tuple) -> bool {
    return tuple_eq(Tuple(a), b);
}

tuple_eq_vt :: #force_inline proc(a: Vector, b: Tuple) -> bool {
    return tuple_eq(Tuple(a), b);
}


add_t :: #force_inline proc(a_, b_: Tuple) -> Tuple {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    return a + b;
}

add_v :: #force_inline proc(a_, b_: Vector) -> Vector {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    return a + b;
}

add_pv :: #force_inline proc(a_: Point, b_: Vector) -> Point {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
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

sub_t :: #force_inline proc(a_, b_: Tuple) -> Tuple  {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    return a - b;
}

sub_p :: #force_inline proc(a_, b_: Point) -> Vector {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    assert(is_point(a));
    assert(is_point(b));

    result := Vector(a - b);

    assert(is_vector(result));

    return result;
}

sub_v :: #force_inline proc(a_, b_: Vector) -> Vector {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    return a - b;
}

sub_pv :: #force_inline proc(a_: Point, b_: Vector) -> Point {
    a, b := a_, b_; // @HACK: Cant use array arithmatic on arguments directly
    assert(is_point(a));
    assert(is_vector(b));

    result := Point(a - Point(b));

    assert(is_point(result));

    return result;
}

sub :: proc { sub_t, sub_p, sub_v, sub_pv };

negate :: #force_inline proc(t_: $T/Tuple) -> T {
    t := t_; // @HACK: Cant use array arithmatic on arguments directly
    return -t;
}

mul_t :: #force_inline proc(t_: Tuple, s: real) -> Tuple {
    t := t_; // @HACK: Cant use array arithmatic on arguments directly
    return t * s;
}

mul_v :: #force_inline proc(v_: Vector, s: real) -> Vector {
    v := v_; // @HACK: Cant use array arithmatic on arguments directly
    return Vector(mul_t(Tuple(v), s));
}


div_t :: #force_inline proc(t_: Tuple, s: real) -> Tuple {
    t := t_; // @HACK: Cant use array arithmatic on arguments directly
    return t / s;
}

div :: proc { div_t };

magnitude :: proc(v_: Vector) -> real {
    v := v_; // @HACK: Cant use array arithmatic on arguments directly
    sum := simd.reduce_add_ordered(simd.from_array(v * v));
    return cm.sqrt(sum);

    /*return cm.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);*/
}

normalize :: proc(v_: Vector) -> Vector {
    v := v_; // @HACK: Can't use array arithmatic on arguments directly
    m := magnitude(v);
    return v / m;
}

dot :: proc(a_, b_: Vector) -> real {
    a, b := a_, b_; // @HACK: Can't use array arithmatic on arguments directly
    return simd.reduce_add_ordered(simd.from_array(a * b));
}

cross :: proc(a_, b_: Vector) -> Vector {
    a, b := a_, b_; // @HACK: Can't use array arithmatic on arguments directly
    return a.yzxw * b.zxyw - a.zxyw * b.yzxw;
}

reflect :: proc(v, n: Vector) ->  Vector {
    return sub(v, mul(n, 2 * dot(v, n)));
}

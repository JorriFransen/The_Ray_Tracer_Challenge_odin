package rtmath

import "core:fmt"
import "core:intrinsics"
import "core:simd"
import cm "core:math"

Tuple_Element_Type :: f32;

Tuple :: distinct [4]Tuple_Element_Type;
Point :: distinct Tuple;
Vector :: distinct Tuple;

tuple :: proc(x, y, z, w: Tuple_Element_Type) -> Tuple {
    return Tuple { x, y, z, w };
}

point :: proc(x, y, z: Tuple_Element_Type) -> Point {
    return Point { x, y, z, 1.0 };
}

vector :: proc(x, y, z: Tuple_Element_Type) -> Vector {
    return Vector { x, y, z, 0.0 };
}

is_point :: proc(t: $T/Tuple) -> bool {
    return t.w == 1.0;
}

is_vector :: proc(t: $T/Tuple) -> bool {
    return t.w == 0.0;
}

tuple_eq :: proc(a, b: $T/[4]Tuple_Element_Type) -> bool {
    simd_diff := simd.abs(simd.from_array(a) - simd.from_array(b));
    simd_epsilon : #simd[4]Tuple_Element_Type : { FLOAT_EPSILON, FLOAT_EPSILON, FLOAT_EPSILON, FLOAT_EPSILON };

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

negate :: #force_inline proc(t: $T/Tuple) -> T {
    return -t;
}

mul_t :: #force_inline proc(t: Tuple, s: Tuple_Element_Type) -> Tuple {
    return t * s;
}

mul_v :: #force_inline proc(v: Vector, s: Tuple_Element_Type) -> Vector {
    return Vector(mul_t(Tuple(v), s));
}


div_t :: #force_inline proc(t: Tuple, s: Tuple_Element_Type) -> Tuple {
    return t / s;
}

div :: proc { div_t };

magnitude :: proc(v: Vector) -> Tuple_Element_Type {

    sum := simd.reduce_add_ordered(simd.from_array(v * v));
    return cm.sqrt(sum);

    /*return cm.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);*/
}

normalize :: proc(v: Vector) -> Vector {
    m := magnitude(v);
    return v / m;
}

dot :: proc(a, b: Vector) -> Tuple_Element_Type {
    return simd.reduce_add_ordered(simd.from_array(a * b));
}

cross :: proc(a, b: Vector) -> Vector {
    return a.yzxw * b.zxyw - a.zxyw * b.yzxw;
}

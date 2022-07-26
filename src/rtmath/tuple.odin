package rtmath

import "core:fmt"
import "core:intrinsics"
import cm "core:math"

Tuple :: struct($T: typeid) where intrinsics.type_is_float(T) {
    using data : [4]T,
}

Point :: struct($T: typeid) where intrinsics.type_is_float(T) {
    using t : Tuple(T),
}

Vector :: struct($T: typeid) where intrinsics.type_is_float(T) {
    using t : Tuple(T),
}

tuple :: proc($T: typeid, x, y, z, w: T) -> Tuple(T) where intrinsics.type_is_float(T) {
    return Tuple(T) { data = { x, y, z, w } };
}

point :: proc($T: typeid, x, y, z: T) -> Point(T) where intrinsics.type_is_float(T) {
    return Point(T) { t = { data = { x, y, z, 1.0 } } };
}

vector :: proc($T: typeid, x, y, z: T) -> Vector(T) where intrinsics.type_is_float(T) {
    return Vector(T) { t = tuple(T, x, y, z, 0.0 ) };
}


eq :: proc(a, b: $T) -> bool
    where intrinsics.type_is_specialization_of(T, Tuple) ||
          (intrinsics.type_polymorphic_record_parameter_count(T) == 1 &&
          intrinsics.type_is_subtype_of(T, Tuple(intrinsics.type_polymorphic_record_parameter_value(T, 0))))
{
    return eq_internal(a.data, b.data);
}

eq_internal :: proc (v1, v2: $V/[$N]$A) -> bool {

    r := v1 - v2;
    r = transmute(V)intrinsics.simd_abs(transmute(#simd[N]A)r);

    for e in r {
        if (e >= FLOAT_EPSILON) {
            return false;
        }
    }

    return true;
}

is_point :: proc(t: $T) -> bool {
    return t.w == 1.0;
}

is_vector :: proc(t: $T) -> bool {
    return t.w == 0.0;
}

add_poly :: proc(a: $T/Tuple, b: T) -> T {
    return T { data = a.data + b.data };
}

add_point_vector :: proc(a: Point($T), b: Vector(T)) -> Point(T) {
    return Point(T) { add(a.t, b.t) };
}

add_vector_point :: proc(a: Vector($T), b: Point(T)) -> Point(T) {
    return Point(T) { add(a.t, b.t) };
}

add_vector_vector :: proc(a: $T/Vector($K), b: T) -> T {
    return T { add(a.t, b.t) };
}

add :: proc { add_poly, add_point_vector, add_vector_point, add_vector_vector };

sub_tuple :: proc(a: $T/Tuple, b: T) -> T {
    return T { a.data - b.data };
}

sub_point :: proc(a: Point($T), b: Point(T)) -> Vector(T) {
    return Vector(T) { sub(a.t, b.t) };
}

sub_point_vector :: proc(a: Point($T), b: Vector(T)) -> Point(T) {
    return Point(T) { sub(a.t, b.t) };
}

sub_vector :: proc(a: $T/Vector, b: T) -> T {
    return T { sub(a.t, b.t) };
}

sub :: proc { sub_tuple, sub_point, sub_point_vector, sub_vector };

negate :: proc(t: $T) -> T
    where intrinsics.type_is_specialization_of(T, Tuple) ||
          intrinsics.type_is_specialization_of(T, Vector){

    // This should just be 2 overloads?
    when intrinsics.type_is_specialization_of(T, Tuple) {
        return T { -t.data };
    } else when intrinsics.type_is_specialization_of(T, Vector) {
        return T { t = { -t.data } };
    } else {
        #assert(false);
    }
}

tuple_mul :: proc(t: Tuple($T), s: T) -> Tuple(T) {
    return Tuple(T) { t.data * s } ;
}

mul :: proc { tuple_mul };

tuple_div :: proc(t: Tuple($T), s: T) -> Tuple(T) {
    return Tuple(T) { t.data / s } ;
}

div :: proc { tuple_div };

magnitude :: proc(v: Vector($T)) -> T {
    return cm.sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
}

normalize :: proc(v: $T/Vector) -> T {
    magnitude := magnitude(v);

    result := v.t.data / magnitude;

    assert(is_vector(result));
    return T { t = { data = result } };
}

dot :: proc(a: Vector($T), b: Vector(T)) -> T {
    return a.x * b.x +
           a.y * b.y +
           a.z * b.z +
           a.w + b.w;
}

// Lookat odin's getting started for a possibly faster (simd) approach
cross :: proc(a: $T/Vector($K), b: T) -> T {
    return vector(K, a.y * b.z - a.z * b.y,
                     a.z * b.x - a.x * b.z,
                     a.x * b.y - a.y * b.x);
}

package rtmath

import "core:fmt"
import cm "core:math"

Tuple :: distinct [4]f32;

Point :: struct {
    using t : Tuple,
}

Vector :: struct {
    using t : Tuple,
}

tuple :: proc(x: f32, y: f32, z: f32, w: f32) -> Tuple {
    return Tuple { x, y, z, w };
}

point :: proc(x: f32, y: f32, z: f32) -> Point {
    return Point { Tuple { x, y, z, 1.0 } };
}

vector :: proc(x: f32, y: f32, z: f32) -> Vector {
    return Vector { Tuple { x, y, z, 0.0 } };
}

eq :: proc(a: Tuple, b: Tuple) -> bool {
    return float_eq(a.x, b.x) &&
           float_eq(a.y, b.y) &&
           float_eq(a.z, b.z) &&
           float_eq(a.w, b.w);
}

is_point :: proc(t: Tuple) -> bool {
    return t.w == 1.0;
}

is_vector :: proc(t: Tuple) -> bool {
    return t.w == 0.0;
}

add :: proc(a: Tuple, b: Tuple) -> Tuple {
    return a + b;
}

sub :: proc(a: Tuple, b: Tuple) -> Tuple {
    return a - b;
}

negate :: proc(t: Tuple) -> Tuple {
    return -t;
}

tuple_mul :: proc(t: Tuple, s: f32) -> Tuple {
    return t * s;
}

mul :: proc { tuple_mul };

tuple_div :: proc(t: Tuple, s: f32) -> Tuple {
    return t / s;
}

div :: proc { tuple_div };

magnitude :: proc(v: Vector) -> f32 {
    return cm.sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
}

normalize :: proc(v: Vector) -> Vector {
    magnitude := magnitude(v);

    result := v.t / magnitude;

    assert(is_vector(result));
    return Vector { result };
}

dot :: proc(a: Vector, b: Vector) -> f32 {
    return a.x * b.x +
           a.y * b.y +
           a.z * b.z +
           a.w + b.w;
}

cross :: proc(a: Vector, b: Vector) -> Vector {
    return vector(a.y * b.z - a.z * b.y,
                  a.z * b.x - a.x * b.z,
                  a.x * b.y - a.y * b.x);
}

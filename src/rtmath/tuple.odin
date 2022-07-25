package rtmath

import "core:fmt"
import cm "core:math"

Tuple :: struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

Point :: distinct Tuple;
Vector :: distinct Tuple;

point :: proc(x: f32, y: f32, z: f32) -> Point {
    return Point(Tuple {x, y, z, 1.0});
}

vector :: proc(x: f32, y: f32, z: f32) -> Vector {
    return Vector(Tuple {x, y, z, 0.0});
}

tuple_eq :: proc(a: Tuple, b: Tuple) -> bool {
    return float_eq(a.x, b.x) &&
           float_eq(a.y, b.y) &&
           float_eq(a.z, b.z) &&
           float_eq(a.w, b.w);
}

vector_eq :: proc(a: Vector, b: Vector) -> bool {
    assert(is_vector(a));
    assert(is_vector(b));

    result := tuple_eq(Tuple(a), Tuple(b));

    return result;
}

eq :: proc { tuple_eq, vector_eq };

tuple_is_point :: proc(t: Tuple) -> bool {
    return t.w == 1.0;
}

point_is_point :: proc(p: Point) -> bool {
    assert(p.w == 1.0);
    return true;
}

vector_is_point :: proc(v: Vector) -> bool {
    assert(v.w == 0.0);
    return false;
}

is_point :: proc { tuple_is_point, point_is_point, vector_is_point };

tuple_is_vector :: proc(t: Tuple) -> bool {
    return t.w == 0.0;
}

point_is_vector :: proc (p: Point) -> bool {
    assert(p.w == 1.0);
    return false;
}

vector_is_vector :: proc(v: Vector) -> bool {
    assert(v.w == 0.0);
    return true;
}

is_vector :: proc { tuple_is_vector, point_is_vector, vector_is_vector };

tuple_add :: proc(a: Tuple, b: Tuple) -> Tuple {
    return Tuple { a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w };
}

point_vector_add :: proc(p: Point, v: Vector) -> Point {
    assert(is_point(p));
    assert(is_vector(v));

    result := tuple_add(Tuple(p), Tuple(v));

    assert(is_point(result));
    return Point(result);
}

vector_point_add :: proc(v: Vector, p: Point) -> Point {
    assert(is_vector(v));
    assert(is_point(p));

    result := tuple_add(Tuple(p), Tuple(v));

    assert(is_point(result));
    return Point(result);
}

vector_add :: proc(a: Vector, b: Vector) -> Vector {
    assert(is_vector(a));
    assert(is_vector(b));

    result := tuple_add(Tuple(a), Tuple(b));

    assert(is_vector(result));
    return Vector(result);
}

add :: proc { tuple_add, point_vector_add, vector_point_add, vector_add };

tuple_sub :: proc(a: Tuple, b: Tuple) -> Tuple {
    return Tuple { a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w };
}

point_sub :: proc(a: Point, b: Point) -> Vector {
    assert(is_point(a));
    assert(is_point(b));

    result := tuple_sub(Tuple(a), Tuple(b));

    assert(is_vector(result));
    return Vector(result);
}

point_sub_vector :: proc(p: Point, v: Vector) -> Point {
    assert(is_point(p));
    assert(is_vector(v));

    result := tuple_sub(Tuple(p), Tuple(v));

    assert(is_point(result));
    return Point(result);
}

Vector_Sub :: proc(a: Vector, b: Vector) -> Vector {
    assert(is_vector(a));
    assert(is_vector(b));

    result := tuple_sub(Tuple(a), Tuple(b));

    assert(is_vector(result));
    return Vector(result);
}

sub :: proc { tuple_sub, point_sub, point_sub_vector, Vector_Sub };

tuple_negate :: proc(t: Tuple) -> Tuple {
    return Tuple { -t.x, -t.y, -t.z, -t.w };
}

vector_negate :: proc(v: Vector) -> Vector {
    assert(is_vector(v));

    result := tuple_negate(Tuple(v));

    assert(is_vector(result));
    return Vector(result);
}

negate :: proc { tuple_negate, vector_negate };

tuple_mul :: proc(t: Tuple, s: f32) -> Tuple {
    return Tuple { t.x * s, t.y * s, t.z * s, t.w * s };
}

mul :: proc { tuple_mul };

tuple_div :: proc(t: Tuple, s: f32) -> Tuple {
    return Tuple { t.x / s, t.y / s, t.z / s, t.w / s };
}

div :: proc { tuple_div };

magnitude :: proc(v: Vector) -> f32 {
    return cm.sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
}

normalize :: proc(v: Vector) -> Vector {
    magnitude := magnitude(v);

    result := Tuple { v.x / magnitude, v.y / magnitude, v.z / magnitude, v.w / magnitude };
    assert(is_vector(result));
    return Vector(result);
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

package graphics

import "core:intrinsics"
import m "../rtmath"

Color :: struct($T: typeid) where intrinsics.type_is_float(T) {
    using t: m.Tuple(T),
}

color :: proc($T: typeid, r, g, b: T) -> Color(T) where intrinsics.type_is_float(T) {
    return Color(T) { m.tuple(T, r, g, b, 0.0) };
}

eq :: proc(a: $T/Color, b: T) -> bool {
    return m.eq(a, b);
}

add :: proc(a: $T/Color, b: T) -> T {
    return T { m.add(a.t, b.t) };
}

sub :: proc(a: $T/Color, b: T) -> T {
    return T { m.sub(a.t, b.t) };
}

color_mul_scalar :: proc(c: $T/Color($K) s: K) -> T {
    return T { m.mul(c.t, s) };
}

color_mul :: proc(a: $T/Color, b: T) -> T {
    return T { t = { a.t.data * b.t.data } };
}

mul :: proc { color_mul_scalar, color_mul };

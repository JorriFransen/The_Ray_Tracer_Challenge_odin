package graphics

import "core:intrinsics"
import m "../rtmath"

Color :: distinct m.Tuple;

color :: proc(r, g, b: intrinsics.type_field_type(Color, "r")) -> Color {
    return Color  { r, g, b, 0.0 };
}

eq :: #force_inline proc(a, b: Color) -> bool {
    return m.eq(a, b);
}

add :: #force_inline proc(a, b: Color) -> Color {
    return a + b;
}

sub :: #force_inline proc(a, b: Color) -> Color {
    return a - b;
}

mul_c :: #force_inline proc(a, b: Color) -> Color {
    return a * b;
}

mul_s :: #force_inline proc(c: Color, s: intrinsics.type_field_type(Color, "r")) -> Color {
    return Color(m.mul_t(m.Tuple(c), s));
}

mul :: proc { mul_c, mul_s };

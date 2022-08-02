package graphics

import "core:intrinsics"
import rm "raytracer:math"

Color :: distinct rm.Tuple;

WHITE :: Color { 1, 1, 1, 0 };
BLACK :: Color { 0, 0, 0, 0 };
RED   :: Color { 1, 0, 0, 0 };
GREEN :: Color { 0, 1, 0, 0 };
BLUE  :: Color { 0, 0, 1, 0 };

color :: proc(r, g, b: intrinsics.type_field_type(Color, "r")) -> Color {
    return Color  { r, g, b, 0.0 };
}

eq :: #force_inline proc(a, b: Color) -> bool {
    return rm.eq(a, b);
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
    return Color(rm.mul_t(rm.Tuple(c), s));
}

mul :: proc { mul_c, mul_s };

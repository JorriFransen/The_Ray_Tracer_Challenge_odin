package raytracer

import "core:intrinsics"
import rm "raytracer:math"

Color :: distinct rm.Tuple;

WHITE :: Color { 1, 1, 1, 0 };
BLACK :: Color { 0, 0, 0, 0 };
RED   :: Color { 1, 0, 0, 0 };
GREEN :: Color { 0, 1, 0, 0 };
BLUE  :: Color { 0, 0, 1, 0 };

color :: proc(r, g, b: rm.real) -> Color {
    return Color  { r, g, b, 0.0 };
}

add :: #force_inline proc(a, b: Color) -> Color {
    return a + b;
}

sub :: #force_inline proc(a, b: Color) -> Color {
    return a - b;
}

color_mul_c :: #force_inline proc(a, b: Color) -> Color {
    return a * b;
}

color_mul_s :: #force_inline proc(c: Color, s: rm.real) -> Color {
    return Color(rm.mul_t(rm.Tuple(c), s));
}

package graphics

import m "../rtmath"

Color :: distinct m.Tuple;

color :: proc(r: f32, g: f32, b: f32) -> Color {
    return Color { r, g, b, 0.0};
}

eq :: proc(a: Color, b: Color) -> bool {
    return m.eq(m.Tuple(a), m.Tuple(b));
}

add :: proc(a: Color, b: Color) -> Color {
    return Color(m.add(m.Tuple(a), m.Tuple(b)));
}

sub :: proc(a: Color, b: Color) -> Color {
    return Color(m.sub(m.Tuple(a), m.Tuple(b)));
}

color_mul_scalar :: proc(c: Color, s: f32) -> Color {
    return Color(m.mul(m.Tuple(c), s));
}

color_mul :: proc(a: Color, b: Color) -> Color {
    return a * b;
}

mul :: proc { color_mul_scalar, color_mul };

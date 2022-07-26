package graphics

import m "../rtmath"

Color :: struct {
    using t : m.Tuple,
}

color :: proc(r: f32, g: f32, b: f32) -> Color {
    return Color{ m.Tuple{ r, g, b, 0.0 } };
}

eq :: proc(a: Color, b: Color) -> bool {
    return m.eq(m.Tuple(a), m.Tuple(b));
}

add :: proc(a: Color, b: Color) -> Color {
    return Color { m.add(a, b) };
}

sub :: proc(a: Color, b: Color) -> Color {
    return Color { m.sub(a, b) };
}

color_mul_scalar :: proc(c: Color, s: f32) -> Color {
    return Color { m.mul(c, s) };
}

color_mul :: proc(a: Color, b: Color) -> Color {
    return Color { a.t * b.t };
}

mul :: proc { color_mul_scalar, color_mul };

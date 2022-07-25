package graphics

import m "../rtmath"

_Color :: struct {
    r: f32,
    g: f32,
    b: f32,
}

Color :: struct #raw_union {
    t: m.Tuple,
    using c: _Color,
}

color :: proc(r: f32, g: f32, b: f32) -> Color {
    return Color { t = { r, g, b, 0.0 } };
}

eq :: proc(a: Color, b: Color) -> bool {
    return m.eq(a.t, b.t);
}

add :: proc(a: Color, b: Color) -> Color {
    return transmute(Color)m.add(a.t, b.t);
}

sub :: proc(a: Color, b: Color) -> Color {
    return transmute(Color)m.sub(a.t, b.t);
}

color_mul_scalar :: proc(c: Color, s: f32) -> Color {
    return transmute(Color)m.mul(c.t, s);
}

color_mul :: proc(a: Color, b: Color) -> Color {
    return color(a.r * b.r, a.g * b.g, a.b * b.b);
}

mul :: proc { color_mul_scalar, color_mul };

package raytracer

import "core:math"

import m "raytracer:math"

Pattern_At_Proc :: proc(pat: ^Pattern, p: m.Point) -> Color;

Pattern :: struct {
    a, b: Color,
    inverse_transform: m.Matrix4,
    pattern_at: Pattern_At_Proc,
}

pattern :: proc(pa_proc: Pattern_At_Proc, a, b: Color, tf := m.matrix4_identity) -> (r: Pattern) {
    r.a = a;
    r.b = b;
    set_pattern_transform(&r, tf);
    r.pattern_at = pa_proc;
    return;
}

set_pattern_transform :: proc(pat: ^Pattern, tf: m.Matrix4) {
    pat.inverse_transform = m.matrix_inverse(tf);
}

pattern_at_shape :: proc(pat: ^Pattern, shape: ^Shape, p: m.Point) -> Color {

    obj_p := mul(shape.inverse_transform, p);
    pattern_p := mul(pat.inverse_transform, obj_p);

    return pat->pattern_at(pattern_p);
}

test_pattern :: proc() -> Pattern {

    test_pattern_pattern_at :: proc(pat: ^Pattern, p: m.Point) -> Color {
        return color(p.x, p.y, p.z);
    }

    return pattern(test_pattern_pattern_at, WHITE, BLACK, m.matrix4_identity);
}


stripe_pattern :: proc(a, b: Color, tf := m.matrix4_identity) -> Pattern {

    stripe_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

        if int(math.floor(p.x)) % 2 == 0 do return pat.a;
        return pat.b;
    }

    return pattern(stripe_at, a, b, tf);
}

gradient_pattern :: proc(a, b: Color, tf := m.matrix4_identity) -> Pattern {

    gradient_at :: proc(pat: ^Pattern, p: m.Point) -> Color {
        return add(pat.a, mul(sub(pat.b, pat.a), p.x - math.floor(p.x)));
    }

    return pattern(gradient_at, a, b, tf);
}

ring_pattern :: proc(a, b: Color, tf := m.matrix4_identity) -> Pattern {

    ring_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

        if int(math.floor(p.x * p.x + p.z * p.z)) % 2 == 0 do return pat.a;
        return pat.b
    }

    return pattern(ring_at, a, b, tf);
}

checkers_pattern :: proc(a, b: Color, tf := m.matrix4_identity) -> Pattern {

    checkers_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

        fx := math.floor(f64(p.x));
        fy := math.floor(f64(p.y));
        fz := math.floor(f64(p.z));

        if int(fx + fy + fz) % 2 == 0 do return pat.a;
        return pat.b;
    }

    return pattern(checkers_at, a, b, tf);
}

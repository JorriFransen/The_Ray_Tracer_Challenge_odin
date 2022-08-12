package raytracer

import "core:math"

import m "raytracer:math"

Pattern_At_Proc :: proc(pat: ^Pattern, p: m.Point) -> Color;

Pattern :: struct {
    inverse_transform: m.Matrix4,
    pattern_at: Pattern_At_Proc,

    base_typeid: typeid,
}

Color_Pattern :: struct {
    using pattern: Pattern,
    a, b: Color,
}

Nested_Pattern :: struct {
    using pattern: Pattern,
    a, b: ^Pattern,
}

pattern_base :: proc(pa_proc: Pattern_At_Proc, tf: m.Matrix4, base_type: typeid) -> (r: Pattern) {
    assert(base_type == Nested_Pattern || base_type == Color_Pattern);
    set_pattern_transform(&r, tf);
    r.pattern_at = pa_proc;
    r.base_typeid = base_type;
    return;
}

pattern_nested :: proc(pa_proc: Pattern_At_Proc, a, b: ^Pattern, tf := m.matrix4_identity) -> (r: Nested_Pattern) {
    r.pattern = pattern(pa_proc, tf, Nested_Pattern);
    r.a = a;
    r.b = b;
    return;
}

pattern_color :: proc(pa_proc: Pattern_At_Proc, a, b: Color, tf := m.matrix4_identity) -> (r: Color_Pattern) {
    r.pattern = pattern(pa_proc, tf, Color_Pattern);
    r.a = a;
    r.b = b;
    return;
}

pattern :: proc {
    pattern_base,
    pattern_nested,
    pattern_color,
}

set_pattern_transform :: proc(pat: ^Pattern, tf: m.Matrix4) {
    pat.inverse_transform = m.matrix_inverse(tf);
}

pattern_at_shape :: proc(pat: ^Pattern, shape: ^Shape, p: m.Point) -> Color {

    obj_p := mul(shape.inverse_transform, p);
    return pattern_at(pat, obj_p);
}

@(private="file")
pattern_at :: proc(pat: ^Pattern, obj_p: m.Point) -> Color {

    pattern_p := mul(pat.inverse_transform, obj_p);

    return pat->pattern_at(pattern_p);
}

test_pattern :: proc() -> Color_Pattern {

    test_pattern_at :: proc(pat: ^Pattern, p: m.Point) -> Color {
        return color(p.x, p.y, p.z);
    }

    return pattern_color(test_pattern_at, WHITE, BLACK);
}

solid_color_pattern :: proc(a: Color) -> Color_Pattern {

    solid_color_at :: proc(pat: ^Pattern, p: m.Point) -> Color {
        cpat := transmute(^Color_Pattern)pat;
        return cpat.a;
    }

    return pattern_color(solid_color_at, a, a);
}

@(private="file")
stripe_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

    do_a := int(math.floor(p.x)) % 2 == 0;

    switch pat.base_typeid {

        case Nested_Pattern:
            np := transmute(^Nested_Pattern)pat;
            if do_a do return pattern_at(np.a, p);
            return pattern_at(np.b, p);

        case Color_Pattern:
            cp := transmute(^Color_Pattern)pat;
            if do_a do return cp.a;
            return cp.b;
    }

    assert(false);
    return BLACK;
}

stripe_pattern_p :: proc(a, b: ^Pattern, tf := m.matrix4_identity) -> Nested_Pattern {

    return pattern_nested(stripe_at, a, b, tf);
}

stripe_pattern_c :: proc(a, b: Color, tf := m.matrix4_identity) -> Color_Pattern {

    return pattern_color(stripe_at, a, b, tf);
}

stripe_pattern :: proc {
    stripe_pattern_p,
    stripe_pattern_c,
}

@(private="file")
gradient_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

    ca, cb : Color;

    switch pat.base_typeid {

        case Nested_Pattern:
            np := transmute(^Nested_Pattern)pat;
            ca = pattern_at(np.a, p);
            cb = pattern_at(np.b, p);

        case Color_Pattern:
            cp := transmute(^Color_Pattern)pat;
            ca = cp.a;
            cb = cp.b;
    }

    return add(ca, mul(sub(cb, ca), p.x - math.floor(p.x)));
}

gradient_pattern_p :: proc(a, b: ^Pattern, tf := m.matrix4_identity) -> Nested_Pattern {

    return pattern_nested(gradient_at, a, b, tf);
}

gradient_pattern_c :: proc(a, b: Color, tf := m.matrix4_identity) -> Color_Pattern {

    return pattern_color(gradient_at, a, b, tf);
}

gradient_pattern :: proc {
    gradient_pattern_p,
    gradient_pattern_c,
}

@(private="file")
ring_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

    do_a := int(math.floor(p.x * p.x + p.z * p.z)) % 2 == 0;

    switch pat.base_typeid {
        case Nested_Pattern:
            np := transmute(^Nested_Pattern)pat;
            if do_a do return pattern_at(np.a, p);
            return pattern_at(np.b, p);

        case Color_Pattern:
            cp := transmute(^Color_Pattern)pat;
            if do_a do return cp.a;
            return cp.b;
    }

    assert(false);
    return BLACK;
}

ring_pattern_p :: proc(a, b: ^Pattern, tf := m.matrix4_identity) -> Nested_Pattern {

    return pattern_nested(ring_at, a, b, tf);
}

ring_pattern_c :: proc(a, b: Color, tf := m.matrix4_identity) -> Color_Pattern {

    return pattern_color(ring_at, a, b, tf);
}

ring_pattern :: proc {
    ring_pattern_p,
    ring_pattern_c,
}

@(private="file")
checkers_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

    fx := math.floor(f64(p.x));
    fy := math.floor(f64(p.y));
    fz := math.floor(f64(p.z));

    do_a := int(fx + fy + fz) % 2 == 0;

    switch pat.base_typeid {

        case Nested_Pattern:
            np := transmute(^Nested_Pattern)pat;
            if do_a do return pattern_at(np.a, p);
            return pattern_at(np.b, p);

        case Color_Pattern:
            cp := transmute(^Color_Pattern)pat;
            if do_a do return cp.a;
            return cp.b;
    }

    assert(false);
    return BLACK;
}

checkers_pattern_p :: proc(a, b: ^Pattern, tf := m.matrix4_identity) -> Nested_Pattern {

    return pattern_nested(checkers_at, a, b, tf);
}

checkers_pattern_c :: proc(a, b: Color, tf := m.matrix4_identity) -> Color_Pattern {

    return pattern_color(checkers_at, a, b, tf);
}

checkers_pattern :: proc {
    checkers_pattern_p,
    checkers_pattern_c,
}

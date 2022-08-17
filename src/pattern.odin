package raytracer

import "core:math"
import "core:math/rand"

import m "raytracer:math"

Pattern_At_Proc :: proc(pat: ^Pattern, p: m.Point) -> Color;

Pattern :: struct {
    inverse_transform: m.Matrix4,
    pattern_at: Pattern_At_Proc,

    base_typeid: typeid,
}

Color_Pattern :: struct {
    using base: Pattern,
    a, b: Color,
}

Nested_Pattern :: struct {
    using base: Pattern,
    a, b: ^Pattern,
}

Pattern_Blend_Mode :: enum {
    Normal, // This relies on the alpha of the colors being set (they are not by default).
    Average,
    Dissolve,
    Multiply,
    Screen,
    Overlay,
    Hard_Light,
    Soft_Light,
}

Blended_Pattern :: struct {
    using base: Pattern,
    a, b: ^Pattern,
    mode: Pattern_Blend_Mode,
}

Noise_Pattern :: struct {
    using base: Pattern,
    a, b: ^Pattern,

    noise_proc: m.Noise_Proc,
    frequency: m.real,
    octaves: int,
}

Perturbed_Pattern :: struct {
    using base: Pattern,

    pattern: ^Pattern,
    noise_proc: m.Noise_Proc,
    frequency: m.real,
    octaves: int,

    scale: m.real,
}

pattern_base :: proc(pa_proc: Pattern_At_Proc, tf: m.Matrix4, base_type: typeid) -> (r: Pattern) {

    assert(base_type == Nested_Pattern ||
           base_type == Color_Pattern ||
           base_type == Blended_Pattern ||
           base_type == Noise_Pattern);

    set_pattern_transform(&r, tf);
    r.pattern_at = pa_proc;
    r.base_typeid = base_type;
    return;
}

pattern_nested :: proc(pa_proc: Pattern_At_Proc, a, b: ^Pattern, tf := m.matrix4_identity) -> (r: Nested_Pattern) {
    r.base = pattern(pa_proc, tf, Nested_Pattern);
    r.a = a;
    r.b = b;
    return;
}

pattern_color :: proc(pa_proc: Pattern_At_Proc, a, b: Color, tf := m.matrix4_identity) -> (r: Color_Pattern) {
    r.base = pattern(pa_proc, tf, Color_Pattern);
    r.a = a;
    r.b = b;
    return;
}

pattern :: proc {
    pattern_base,
    pattern_nested,
    pattern_color,
}

@(private="file")
blend_at :: proc(pat: ^Pattern, p: m.Point) -> Color {

    assert(pat.base_typeid == Blended_Pattern);
    bp := transmute(^Blended_Pattern)pat;

    ca := pattern_at(bp.a, p);
    cb := pattern_at(bp.b, p);

    switch bp.mode {
        case .Normal:
            if eq(cb.a, 0) do return ca;
            return ca + (cb * cb.a);

        case .Average: return (ca + cb) / 2;

        case .Dissolve:
            if rand.uint32() % 2 == 0 do return ca;
            return cb;

        case .Multiply: return ca * cb;

        case .Screen: return 1 - ((1 - ca) * (1 - cb));

        case .Overlay:
            avg := (ca.r + ca.g + ca.b) / 3;

            if avg < 0.5 do return 2 * ca * cb;
            return 1 - (2 * (1 - ca) * (1 - cb));

        case .Hard_Light:
            avg := (ca.r + ca.g + ca.b) / 3;

            if avg >= 0.5 do return 2 * ca * cb;
            return 1 - (2 * (1 - ca) * (1 - cb));

        case .Soft_Light:
            return (1 - (2 * cb)) * ca * ca + (2 * cb * ca);

    }

    assert(false);
    return BLACK;
}

blended_pattern :: proc(a, b: ^Pattern, mode := Pattern_Blend_Mode.Average) -> (r: Blended_Pattern) {
    r.base = pattern(blend_at, m.matrix4_identity, Blended_Pattern);
    r.a = a;
    r.b = b;
    r.mode = mode;
    return;
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

@(private="file")
noise_at :: proc(pat: ^Pattern, p: m.Point) -> Color {
    np := transmute(^Noise_Pattern)pat;

    nv := m.noise_sum(np.noise_proc, p, np.frequency, np.octaves) * 0.5 + 0.5;

    a := pattern_at(np.a, p) * nv;
    b := pattern_at(np.b, p) * (1 - nv);

    return a + b;

}

noise_pattern :: proc(a, b: ^Pattern, p: m.Noise_Proc, frequency: m.real, octaves: int) -> (r: Noise_Pattern) {

    assert(frequency > 0);
    assert(octaves >= 0 && octaves <= 8);

    r.base = pattern(noise_at, m.matrix4_identity, Noise_Pattern);
    r.a = a;
    r.b = b;
    r.noise_proc = p;
    r.frequency = frequency;
    r.octaves = octaves;
    return;
}

@(private="file")
perturbed_at :: proc(pat: ^Pattern, p: m.Point) -> Color {
    pp := transmute(^Perturbed_Pattern)pat;

    x := m.noise_sum(pp.noise_proc, p,                          pp.frequency, pp.octaves);
    y := m.noise_sum(pp.noise_proc, m.point(p.x + (x * pp.scale), p.y, p.z), pp.frequency, pp.octaves);
    z := m.noise_sum(pp.noise_proc, m.point(p.x, p.y + (y * pp.scale), p.z), pp.frequency, pp.octaves);

    p := p + m.point(x, y, z) * pp.scale;

    return pattern_at(pp.pattern, p);

}

perturbed_pattern :: proc(pat: ^Pattern, p: m.Noise_Proc, frequency: m.real, octaves: int, scale: m.real) -> (r: Perturbed_Pattern) {

    assert(frequency > 0);
    assert(octaves >= 0 && octaves <= 8);

    r.base = pattern(perturbed_at, m.matrix4_identity, Noise_Pattern);
    r.pattern = pat;
    r.noise_proc = p;
    r.frequency = frequency;
    r.octaves = octaves;
    r.scale = scale;
    return;
}

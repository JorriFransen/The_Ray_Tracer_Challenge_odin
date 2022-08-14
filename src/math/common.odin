package rtmath

import "core:intrinsics"

real :: f32;

FLOAT_EPSILON :: 0.00001;

// OVER_POINT_EPSILON :: FLOAT_EPSILON * 150 when real == f32 else FLOAT_EPSILON;

float_eq :: proc(a, b: real) -> bool {
    return abs(a - b) < FLOAT_EPSILON;
}

eq_arr :: proc(a, b: $T/[$N]$E) -> bool where N != 4 {
    diff := a - b;

    for it in diff {
        if abs(it) >= FLOAT_EPSILON do return false;
    }
    return true;
}

lerp_r :: proc(a, b, t: real) -> real {
    return a * (1 - t) + b * t;
    // return a + (b - a) * t;
}

lerp_p :: proc(a, b: Point, t: real) -> Point {
    return point(lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t));
}

lerp :: proc {
    lerp_r,
    lerp_p,
}


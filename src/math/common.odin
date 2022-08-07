package rtmath

import "core:intrinsics"

real :: f32;

FLOAT_EPSILON :: 0.00001;

OVER_POINT_EPSILON :: FLOAT_EPSILON * 150 when real == f32 else FLOAT_EPSILON;

float_eq :: proc(a, b: real) -> bool {
    return abs(a - b) < FLOAT_EPSILON;
}

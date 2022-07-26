package rtmath

import "core:intrinsics"

FLOAT_EPSILON :: 0.00001;

float_eq :: proc(a, b: $T) -> bool where intrinsics.type_is_float(T) {
    return abs(a - b) < FLOAT_EPSILON;
}

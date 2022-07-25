package rtmath

FLOAT_EPSILON :: 0.00001;

float_eq :: proc(a: f32, b: f32) -> bool {
    return abs(a - b) < FLOAT_EPSILON;
}

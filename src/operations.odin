package raytracer

import rtmath "raytracer:math"

mul :: proc {
    rtmath.mul_t,
    rtmath.mul_v,

    color_mul_c,
    color_mul_s,

    rtmath.matrix4_mul,
    rtmath.matrix4_mul_tuple,
}

eq :: proc {
    rtmath.float_eq,

    rtmath.eq_arr,

    rtmath.tuple_eq,
    rtmath.tuple_eq_pt,
    rtmath.tuple_eq_vt,

    rtmath.matrix4_eq,
    rtmath.matrix3_eq,
    rtmath.matrix2_eq,

    shape_eq,

}

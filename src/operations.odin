package raytracer

import m "math/"

eq :: proc {
    m.float_eq,

    m.eq_arr,

    m.tuple_eq,
    m.tuple_eq_pt,
    m.tuple_eq_vt,

    m.matrix4_eq,
    m.matrix3_eq,
    m.matrix2_eq,

    shape_eq,
}

mul :: proc {
    m.mul_t,
    m.mul_v,

    m.matrix4_mul,
    m.matrix4_mul_tuple,

    color_mul_c,
    color_mul_s,
};


package rtmath

eq_arr :: proc(a, b: $T/[$N]$E) -> bool where N != 4 {
    diff := a - b;

    for it in diff {
        if abs(it) >= FLOAT_EPSILON do return false;
    }
    return true;
}

eq :: proc {
    float_eq,

    eq_arr,

    tuple_eq,
    tuple_eq_pt,
    tuple_eq_vt,

    matrix4_eq,
    matrix3_eq,
    matrix2_eq,
}

mul :: proc {
    mul_t,
    mul_v,

    matrix4_mul,
    matrix4_mul_tuple,
};


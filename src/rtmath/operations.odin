package rtmath

eq_arr :: proc(a, b: $T/[$N]$E) -> bool where N != 4 {
    diff := a - b;

    for _,i in diff {
        if abs(diff[i]) >= FLOAT_EPSILON do return false;
    }
    return true;
}

eq :: proc {
    eq_arr,

    tuple_eq,
    tuple_eq_pt,
    tuple_eq_vt,

    matrix4_eq,
    matrix3_eq,
    matrix2_eq,
}


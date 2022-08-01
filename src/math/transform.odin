package rtmath;

translation :: proc(x, y, z: Tuple_Element_Type) -> Matrix4 {
    return Matrix4 {
        1, 0, 0, x,
        0, 1, 0, y,
        0, 0, 1, z,
        0, 0, 0, 1,
    };
}

scaling :: proc(x, y, z: Tuple_Element_Type) -> Matrix4 {
    return Matrix4 {
        x, 0, 0, 0,
        0, y, 0, 0,
        0, 0, z, 0,
        0, 0, 0, 1,
    };
}

package rtmath;

translation :: proc(x, y, z: Tuple_Element_Type) -> (r: Matrix4) {
    r = matrix4_identity;
    r[0, 3] = x;
    r[1, 3] = y;
    r[2, 3] = z;
    return;
}

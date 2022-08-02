package rtmath;

import "core:math"

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

rotation_x :: proc(r: Tuple_Element_Type) -> Matrix4 {
    return Matrix4 {
        1,           0,            0, 0,
        0, math.cos(r), -math.sin(r), 0,
        0, math.sin(r),  math.cos(r), 0,
        0,           0,            0, 1,
    };
}

rotation_y :: proc(r: Tuple_Element_Type) -> Matrix4 {
    return Matrix4 {
         math.cos(r), 0, math.sin(r), 0,
                   0, 1,           0, 0,
        -math.sin(r), 0, math.cos(r), 0,
                   0, 0,           0, 1,

    };
}

rotation_z :: proc(r: Tuple_Element_Type) -> Matrix4 {
    return Matrix4 {
        math.cos(r), -math.sin(r), 0, 0,
        math.sin(r),  math.cos(r), 0, 0,
                  0,            0, 1, 0,
                  0,            0, 0, 1,
    };
}

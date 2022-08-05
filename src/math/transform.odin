package rtmath;

import "core:math"

translation :: proc(x, y, z: real) -> Matrix4 {
    return Matrix4 {
        1, 0, 0, x,
        0, 1, 0, y,
        0, 0, 1, z,
        0, 0, 0, 1,
    };
}

translate_t :: proc(t: $T/Tuple, x, y, z: real) -> T {
    return translation(x, y, z) * t;
}

translate_m :: proc(m: Matrix4, x, y, z: real) -> Matrix4 {
    return translation(x, y, z) * m;
}

translate :: proc {
    translate_t,
    translate_m,
}

scaling :: proc(x, y, z: real) -> Matrix4 {
    return Matrix4 {
        x, 0, 0, 0,
        0, y, 0, 0,
        0, 0, z, 0,
        0, 0, 0, 1,
    };
}

scale_t :: proc(t: $T/Tuple, x, y, z: real) -> T {
    return scaling(x, y, z) * t;
}

scale_m :: proc(m: Matrix4, x, y, z: real) -> Matrix4 {
    return scaling(x, y, z) * m;
}

scale :: proc {
    scale_t,
    scale_m,
}

rotation_x :: proc(r: real) -> Matrix4 {
    return Matrix4 {
        1,           0,            0, 0,
        0, math.cos(r), -math.sin(r), 0,
        0, math.sin(r),  math.cos(r), 0,
        0,           0,            0, 1,
    };
}

rotate_x_t :: proc(t: $T/Tuple, r: real) -> T {
    return rotation_x(r) * t;
}

rotate_x_m :: proc(m: Matrix4, r: real) -> Matrix4 {
    return rotation_x(r) * m;
}

rotate_x :: proc {
    rotate_x_t,
    rotate_x_m,
}

rotation_y :: proc(r: real) -> Matrix4 {
    return Matrix4 {
         math.cos(r), 0, math.sin(r), 0,
                   0, 1,           0, 0,
        -math.sin(r), 0, math.cos(r), 0,
                   0, 0,           0, 1,

    };
}

rotate_y_t :: proc(t: $T/Tuple, r: real) -> T {
    return rotation_y(r) * t;
}

rotate_y_m :: proc(m: Matrix4, r: real) -> Matrix4 {
    return rotation_y(r) * m;
}

rotate_y :: proc {
    rotate_y_t,
    rotate_y_m,
}

rotation_z :: proc(r: real) -> Matrix4 {
    return Matrix4 {
        math.cos(r), -math.sin(r), 0, 0,
        math.sin(r),  math.cos(r), 0, 0,
                  0,            0, 1, 0,
                  0,            0, 0, 1,
    };
}

rotate_z_t :: proc(t: $T/Tuple, r: real) -> T {
    return rotation_z(r) * t;
}

rotate_z_m :: proc(m: Matrix4, r: real) -> Matrix4 {
    return rotation_z(r) * m;
}

rotate_z :: proc {
    rotate_z_t,
    rotate_z_m,
}

shearing :: proc(xy, xz, yx, yz, zx, zy: real) -> Matrix4 {
    return Matrix4 {
        1, xy, xz, 0,
        yx, 1, yz, 0,
        zx, zy, 1, 0,
        0,  0,  0, 1,
    };
}

shear_t :: proc(t: $T/Tuple, xy, xz, yx, yz, zx, zy: real) -> T {
    return shearing(xy, xz, yx, yz, zx, zy) * t;
}

shear_m :: proc(m: Matrix4, xy, xz, yx, yz, zx, zy: real) -> Matrix4 {
    return shearing(xy, xz, yx, yz, zx, zy) * m;
}

shear :: proc {
    shear_t,
    shear_m,
}

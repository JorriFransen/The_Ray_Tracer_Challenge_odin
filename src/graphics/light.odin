package graphics

import m "raytracer:math"

Point_Light :: struct {
    position: m.Point,
    intensity : Color,
}

point_light :: proc(p: m.Point, i: Color) -> Point_Light {
    return Point_Light { p, i };
}

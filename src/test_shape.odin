package raytracer

import m "raytracer:math"

Test_Shape :: struct {
    using shape: Shape,

    saved_ray: m.Ray,
}

test_shape :: proc(sb: $T/^Shapes) -> ^Test_Shape {

    return shape(sb, &sb.test_shapes);

}

test_shape_normal_at :: proc(ts: ^Test_Shape, p: m.Point) -> m.Vector {
    return m.vector(p.x, p.y, p.z)
}

test_shape_intersects :: proc(ts: ^Test_Shape, r: m.Ray) -> Maybe([2]Intersection) {
    ts.saved_ray = r;
    return nil;
}

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

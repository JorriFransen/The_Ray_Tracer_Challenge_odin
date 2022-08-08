package world_shapes

import m "raytracer:math"
import g "raytracer:graphics"

Test_Shape :: struct {
    using shape: Shape,
}

test_shape :: proc(sb: $T/^Shapes) -> ^Test_Shape {

    return shape(sb, &sb.test_shapes);

}

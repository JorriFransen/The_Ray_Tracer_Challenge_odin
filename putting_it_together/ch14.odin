package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math/rand"
import "core:math"
import "core:fmt";

CH14_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 14.1");

    _spheres : [dynamic]rt.Shape;

    for i in 0..<2 {

        placed := false;

        for {

            x := rand.float64_range(-3, 3)
            z := rand.float64_range(0, 5)
            scale := rand.float64_range(0.2, 0.5);

            transform := m.translation(x, scale, z) * m.scaling(scale, scale, scale);

            hit := false;

            for s in &_spheres {
                my_point := transform * m.point(1, 1, 1);
                other_point := m.matrix4_mul_tuple(m.matrix_inverse(s.inverse_transform), m.point(1, 1, 1));

                d := m.magnitude(m.sub(my_point, other_point));

                // Assuming uniform scale
                if d < abs(scale + s.inverse_transform[0, 0]) {
                    hit = true;
                    break;
                }
            }

            if !hit {
                sphere := rt.sphere(transform);
                append(&_spheres, sphere);

                break;
            }
        }
    }

    shapes := make([]^rt.Shape, len(_spheres) + 1);
    defer delete(shapes);

    floor := rt.plane();
    shapes[0] = &floor;

    for i := 0; i < len(_spheres); i += 1 {
        shapes[i + 1] = &_spheres[i];
    }

    // for s, i in &_shapes {
    //     shapes[i] = &s;
    // }

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 3, -4), m.point(0, 0, 4), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch14.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

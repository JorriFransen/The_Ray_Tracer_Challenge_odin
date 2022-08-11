package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH10_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 10.1");

    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);
    // floor_mat.pattern = rt.stripe_pattern(rt.RED, rt.BLUE);
    // floor_mat.pattern = rt.ring_pattern(rt.RED, rt.BLUE);
    floor_mat.pattern = rt.checkers_pattern(rt.GREEN, rt.WHITE);

    floor := rt.plane(floor_mat);

    sphere1_mat := rt.material();
    sphere1_mat.pattern = rt.gradient_pattern(rt.GREEN, rt.RED, m.translation(1, 0, 0) * m.scaling(2, 2, 2));
    sphere1 := rt.sphere(m.translation(-1.5, 0.5, -0.7) * m.scaling(0.5, 0.5, 0.5), sphere1_mat);

    sphere2_mat := rt.material();
    sphere2_mat.pattern = rt.ring_pattern(rt.YELLOW, rt.RED, m.scaling(.3, 1, .3));
    sphere2 := rt.sphere(m.translation(0, 0.5, -0.7) * m.scaling(0.5, 0.5, 0.5), sphere2_mat);

    sphere3_mat := rt.material();
    sphere3_mat.pattern = rt.checkers_pattern(rt.GREEN, rt.WHITE, m.scaling(0.5, 0.5, 0.5));
    sphere3 := rt.sphere(m.translation(1.5, .5, -0.7) * m.scaling(0.5, 0.5, 0.5), sphere3_mat);

    shapes := []^rt.Shape { &floor, &sphere1, &sphere2, &sphere3 };

    lights := []rt.Point_Light {
        rt.point_light(m.point(0, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch10.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

CH10_2 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 10.1");

    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);

    floor := rt.plane(floor_mat);

    shapes := []^rt.Shape { &floor};

    lights := []rt.Point_Light {
        rt.point_light(m.point(0, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch10.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH10_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 10.1");

    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);
    floor_pat := rt.checkers_pattern(rt.GREEN, rt.WHITE);
    floor_mat.pattern = &floor_pat;

    floor := rt.plane(floor_mat);

    sphere1_mat := rt.material();
    sphere1_pat := rt.gradient_pattern(rt.GREEN, rt.RED, m.translation(1, 0, 0) * m.scaling(2, 2, 2));
    sphere1_mat.pattern = &sphere1_pat;
    sphere1 := rt.sphere(m.translation(-1.5, 0.5, -0.7) * m.scaling(0.5, 0.5, 0.5), sphere1_mat);

    sphere2_mat := rt.material();
    sphere2_pat := rt.ring_pattern(rt.YELLOW, rt.RED, m.scaling(.3, 1, .3));
    sphere2_mat.pattern = &sphere2_pat;
    sphere2 := rt.sphere(m.translation(0, 0.5, -0.7) * m.scaling(0.5, 0.5, 0.5), sphere2_mat);

    sphere3_mat := rt.material();
    sphere3_pat := rt.checkers_pattern(rt.GREEN, rt.WHITE, m.scaling(0.5, 0.5, 0.5));
    sphere3_mat.pattern = &sphere3_pat;
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
    fmt.println("Putting it together for chapter 10.2");


    stripe_rot := m.real(PI / 4);
    stripe_scaler : m.real = 0.33;
    stripe_scale := m.scaling(stripe_scaler, stripe_scaler, stripe_scaler);

    floor_stripes1 := rt.stripe_pattern(rt.color(0.3333, 0.008, 0), rt.color(0.831, 0.427, 0.416), stripe_scale * m.rotation_y(stripe_rot));
    floor_stripes2 := rt.stripe_pattern(rt.color(0.329, 0.655, 0.349), rt.color(0, 0.263, 0.016), stripe_scale * m.rotation_y(-stripe_rot));

    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);
    floor_pat := rt.checkers_pattern(&floor_stripes1, &floor_stripes2, m.rotation_y(-PI / 32));
    floor_mat.pattern = &floor_pat;

    floor := rt.plane(floor_mat);
    shapes := []^rt.Shape { &floor };

    lights := []rt.Point_Light {
        rt.point_light(m.point(0, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch10.2.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

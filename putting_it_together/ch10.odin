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

CH10_3 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 10.3");


    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);
    stripe_scale := m.scaling(0.5, 0.5, 0.5);

    stripe_white := rt.WHITE;
    stripe_white.a = 0.5;
    stripe_green := rt.color(0.2, .5, 0.2);
    stripe_green.a = 0.5;

    stripes1 := rt.stripe_pattern(stripe_white, stripe_green, stripe_scale * m.rotation_y(PI / 4));
    stripes2 := rt.stripe_pattern(stripe_white, stripe_green, stripe_scale * m.rotation_y(-PI / 4));

    stripes_blend := rt.blended_pattern(&stripes1, &stripes2, .Average);

    floor_mat.pattern = &stripes_blend;

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

    ok := rt.ppm_write_to_file("images/putting_it_together_ch10.3.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

CH10_4 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 10.4");


    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);
    stripe_scale := m.scaling(0.5, 0.5, 0.5);

    white := rt.WHITE;
    green := rt.color(0.2, .5, 0.2);
    yellow := rt.color(1, 1, 0);

    pat_green := rt.solid_color_pattern(green);

    stripes := rt.stripe_pattern(white, yellow, stripe_scale);

    noise_pat := rt.noise_pattern(&stripes, &pat_green, m.perlin_noise_3D, 1, 3);

    floor_mat.pattern = &noise_pat;

    floor := rt.plane(m.rotation_x(-PI/2), floor_mat);
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

    ok := rt.ppm_write_to_file("images/putting_it_together_ch10.4.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

CH10_5 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 10.5");


    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);

    stripes1_pat := rt.stripe_pattern(rt.RED, rt.WHITE);
    stripes2_pat := rt.stripe_pattern(rt.RED, rt.WHITE, m.rotation_y(PI / 2));
    blend_stripes_pat := rt.blended_pattern(&stripes1_pat, &stripes2_pat, .Multiply);
    floor_pat := rt.perturbed_pattern(&blend_stripes_pat, m.perlin_noise_3D, 2, 2, 0.7);
    floor_pat.inverse_transform = m.matrix_inverse(m.scaling(0.5, 0.5, 0.5));

    floor_mat.pattern = &floor_pat;
    floor := rt.plane(floor_mat);

    sphere1_mat := rt.material(color=rt.color(0.2, 0.9, 0.2));

    sphere_ring_pat := rt.stripe_pattern(rt.GREEN, rt.color(0.2, 0.7, 0.2), m.scaling(0.3, 0.2, 0.3) * m.rotation_y(-PI/4) * m.rotation_z(-PI / 4));
    sphere_pat := rt.perturbed_pattern(&sphere_ring_pat, m.perlin_noise_3D, 3.4, 3, 0.4);

    sphere1_mat.pattern = &sphere_pat;
    sphere1_tf := m.translation(-1.2, 0.9, 0.8) * m.scaling(0.9, 0.9, 0.9);
    sphere1 := rt.sphere(sphere1_tf, sphere1_mat);

    sphere2_mat := rt.material();

    gradient_pat := rt.gradient_pattern(rt.RED, rt.GREEN,  m.scaling(2, 2, 2) * m.translation(0.3, 0, 0));
    sphere2_pat := rt.perturbed_pattern(&gradient_pat, m.perlin_noise_3D, 4, 2, 0.2);
    sphere2_mat.pattern = &sphere2_pat;
    sphere2_tf := m.translation(1.2, 0.5, -0.75) * m.scaling(0.5, 0.5, 0.5);
    sphere2 := rt.sphere(sphere2_tf, sphere2_mat);

    shapes := []^rt.Shape { &floor, &sphere1, &sphere2 };

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch10.5.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

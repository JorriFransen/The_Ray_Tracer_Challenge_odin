package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH11_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 11.1");


    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);

    stripes1_pat := rt.stripe_pattern(rt.RED, rt.WHITE);
    stripes2_pat := rt.stripe_pattern(rt.RED, rt.WHITE, m.rotation_y(PI / 2));
    blend_stripes_pat := rt.blended_pattern(&stripes1_pat, &stripes2_pat, .Multiply);
    floor_pat := rt.perturbed_pattern(&blend_stripes_pat, m.perlin_noise_3D, 2, 2, 1);
    floor_pat.inverse_transform = m.matrix_inverse(m.scaling(0.5, 0.5, 0.5));

    floor_mat.pattern = &floor_pat;
    floor := rt.plane(floor_mat);

    sphere1_mat := rt.material(color=rt.color(0.2, 0.9, 0.2), reflective=0.3);

    sphere_ring_pat := rt.stripe_pattern(rt.GREEN, rt.color(0.2, 0.7, 0.2), m.scaling(0.3, 0.2, 0.3) * m.rotation_y(-PI/4) * m.rotation_z(-PI / 4));
    sphere_pat := rt.perturbed_pattern(&sphere_ring_pat, m.perlin_noise_3D, 3.4, 3, 0.7);

    sphere1_mat.pattern = &sphere_pat;
    sphere1_tf := m.translation(-1.2, 0.9, 0.8) * m.scaling(0.9, 0.9, 0.9);
    sphere1 := rt.sphere(sphere1_tf, sphere1_mat);

    sphere2_mat := rt.material(reflective=0.1);

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

    ok := rt.ppm_write_to_file("images/putting_it_together_ch11.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

CH11_2 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 11.2");


    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);

    stripes1_pat := rt.stripe_pattern(rt.RED, rt.WHITE);
    stripes2_pat := rt.stripe_pattern(rt.RED, rt.WHITE, m.rotation_y(PI / 2));
    blend_stripes_pat := rt.blended_pattern(&stripes1_pat, &stripes2_pat, .Multiply);
    floor_pat := rt.perturbed_pattern(&blend_stripes_pat, m.perlin_noise_3D, 2, 2, 1);
    floor_pat.inverse_transform = m.matrix_inverse(m.scaling(0.5, 0.5, 0.5));

    floor_mat.pattern = &floor_pat;
    floor := rt.plane(floor_mat);

    sphere1_mat := rt.material(color=rt.color(0.2, 0.9, 0.2), reflective=0.9, transparency=.8, diffuse=.3, refractive_index=2.417);

    sphere1_tf := m.translation(-1.2, 0.9, 0.8) * m.scaling(0.9, 0.9, 0.9);
    sphere1 := rt.sphere(sphere1_tf, sphere1_mat);

    sphere2_mat := rt.material(reflective=0.9, transparency=0.9, diffuse=.1, refractive_index=1.005);

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

    ok := rt.ppm_write_to_file("images/putting_it_together_ch11.2.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

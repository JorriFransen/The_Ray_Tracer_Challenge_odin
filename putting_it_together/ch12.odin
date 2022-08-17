package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH12_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 12.1");


    floor_mat := rt.material(color=rt.color(.9, .9, .9), specular=0);

    stripes1_pat := rt.stripe_pattern(rt.RED, rt.WHITE);
    stripes2_pat := rt.stripe_pattern(rt.RED, rt.WHITE, m.rotation_y(PI / 2));
    blend_stripes_pat := rt.blended_pattern(&stripes1_pat, &stripes2_pat, .Multiply);
    floor_pat := rt.perturbed_pattern(&blend_stripes_pat, m.perlin_noise_3D, 2, 2, 1);
    floor_pat.inverse_transform = m.matrix_inverse(m.scaling(0.5, 0.5, 0.5));

    floor_mat.pattern = &floor_pat;
    floor := rt.plane(floor_mat);

    sphere1_mat := rt.material(color=rt.color(0.2, 0.9, 0.2), reflective=0.9, transparency=.8, diffuse=.3, refractive_index=2.417);

    sphere1_tf := m.translation(-0.7, 0.9, 0.8) * m.scaling(0.9, 0.9, 0.9);
    sphere1 := rt.sphere(sphere1_tf, sphere1_mat);

    sphere2_mat := rt.material(reflective=0.9, transparency=0.9, diffuse=.1, refractive_index=1.005);

    sphere2_tf := m.translation(1.7, 0.5, -0.75) * m.scaling(0.5, 0.5, 0.5);
    sphere2 := rt.sphere(sphere2_tf, sphere2_mat);

    cube1 := rt.cube(m.translation(0.5, 0, 0) * m.rotation_y(PI / 4) * m.scaling(0.5, 0.5, 0.5),
                    rt.material(color=rt.color(0.3, 0.4, 0.8), reflective=.1));

    cube2 := rt.cube(m.translation(-3, 0.5, 1) * m.rotation_y(0) * m.scaling(0.5, 0.5, 0.5),
                    rt.material(color=rt.color(0.8, 0.2, 0.3), reflective=.1, specular=.5));

    cube3 := rt.cube(m.translation(2.5, 0.4999, 1) * m.rotation_y(0) * m.scaling(0.5, 0.5, 0.5),
                    rt.material(color=rt.color(0.2, 0.75, 0.3), reflective=.77, specular=.9, transparency=.77, diffuse=.1));

    shapes := []^rt.Shape { &floor, &sphere1, &sphere2, &cube1, &cube2, &cube3 };

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch12.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

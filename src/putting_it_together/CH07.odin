package putting_it_together

import m "raytracer:math"
import g "raytracer:graphics"
import w "raytracer:world"

import "core:math"
import "core:fmt";

CH07 :: proc(c: g.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 7");


    floor_mat := g.material(color=g.color(0.9, 0.9, 0.9), specular=0);
    floor := w.sphere(m.scaling(10, 0.01, 10), floor_mat);
    left_wall := w.sphere(m.translate(m.rotate_y(m.rotate_x(m.scaling(10, 0.01, 10), PI / 2), -PI / 4), 0, 0, 5), floor_mat);
    right_wall := w.sphere(m.translate(m.rotate_y(m.rotate_x(m.scaling(10, 0.01, 10), PI / 2), PI / 4), 0, 0, 5), floor_mat);

    sphere_mat := g.material(diffuse=0.7, specular=0.3);
    middle_sphere := w.sphere(m.translation(-0.5, 1, 0.5), g.material(sphere_mat, g.color(0.1, 1, 0.5)));
    right_sphere := w.sphere(m.translate(m.scaling(0.5, 0.5, 0.5), 1.5, 0.5, -0.5), g.material(sphere_mat, g.color(0.5, 1, 0.1)));
    left_sphere := w.sphere(m.translate(m.scaling(0.33, 0.33, 0.33), -1.5, 0.33, -0.75), g.material(sphere_mat, g.color(1, 0.8, 0.1)));

    shapes := []w.Shape { floor, left_wall, right_wall, middle_sphere, right_sphere, left_sphere };
    lights := []g.Point_Light { g.point_light(m.point(-10, 10, -10), g.color(1, 1, 1)) };

    world := w.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := w.camera(c.width, c.height, PI / 3, view_transform)

    w.render(&c, &camera, &world);

    ppm := g.ppm_from_canvas(c);
    defer delete(ppm);

    ok := g.ppm_write_to_file("images/putting_it_together_ch07.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

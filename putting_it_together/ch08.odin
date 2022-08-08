
package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH08 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 8");

    sb : rt.Shapes(8);

    floor_mat := rt.material(color=rt.color(0.9, 0.9, 0.9), specular=0);
    floor := rt.sphere(&sb, m.scaling(10, 0.01, 10), floor_mat);
    left_wall := rt.sphere(&sb, m.translate(m.rotate_y(m.rotate_x(m.scaling(10, 0.01, 10), PI / 2), -PI / 4), 0, 0, 5), floor_mat);
    right_wall := rt.sphere(&sb, m.translate(m.rotate_y(m.rotate_x(m.scaling(10, 0.01, 10), PI / 2), PI / 4), 0, 0, 5), floor_mat);

    sphere_mat := rt.material(diffuse=0.7, specular=0.3);
    middle_sphere := rt.sphere(&sb, m.translation(-0.5, 1, 0.5), rt.material(sphere_mat, rt.color(0.1, 1, 0.5)));
    right_sphere := rt.sphere(&sb, m.translate(m.scaling(0.5, 0.5, 0.5), 1.5, 0.5, -0.5), rt.material(sphere_mat, rt.color(0.5, 1, 0.1)));
    left_sphere := rt.sphere(&sb, m.translate(m.scaling(0.33, 0.33, 0.33), -1.5, 0.33, -0.75), rt.material(sphere_mat, rt.color(1, 0.8, 0.1)));

    small_sphere_mat := rt.material(shininess = 1000, specular = 1);
    small_sphere1 := rt.sphere(&sb, m.translate(m.scaling(.2, .2, .2), 0, .2, -1), small_sphere_mat);
    small_sphere2 := rt.sphere(&sb, m.translate(m.scaling(.2, .2, .2), .8, .2, .2), rt.material(small_sphere_mat, rt.color(.8, .2, .2)));

    shapes := []^rt.Shape { floor, left_wall, right_wall, middle_sphere, right_sphere, left_sphere, small_sphere1, small_sphere2 };

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.color(.8, .8, .8)),
        rt.point_light(m.point(10, 10, -10), rt.color(.3, .1, .1)),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch08.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}


package putting_it_together

import m "raytracer:math"
import g "raytracer:graphics"
import w "raytracer:world"
import s "raytracer:world/shapes"

import "core:math"
import "core:fmt";

CH08 :: proc(c: g.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 8");

    sb : s.Shapes(8);

    floor_mat := g.material(color=g.color(0.9, 0.9, 0.9), specular=0);
    floor := s.sphere(&sb, m.scaling(10, 0.01, 10), floor_mat);
    left_wall := s.sphere(&sb, m.translate(m.rotate_y(m.rotate_x(m.scaling(10, 0.01, 10), PI / 2), -PI / 4), 0, 0, 5), floor_mat);
    right_wall := s.sphere(&sb, m.translate(m.rotate_y(m.rotate_x(m.scaling(10, 0.01, 10), PI / 2), PI / 4), 0, 0, 5), floor_mat);

    sphere_mat := g.material(diffuse=0.7, specular=0.3);
    middle_sphere := s.sphere(&sb, m.translation(-0.5, 1, 0.5), g.material(sphere_mat, g.color(0.1, 1, 0.5)));
    right_sphere := s.sphere(&sb, m.translate(m.scaling(0.5, 0.5, 0.5), 1.5, 0.5, -0.5), g.material(sphere_mat, g.color(0.5, 1, 0.1)));
    left_sphere := s.sphere(&sb, m.translate(m.scaling(0.33, 0.33, 0.33), -1.5, 0.33, -0.75), g.material(sphere_mat, g.color(1, 0.8, 0.1)));

    small_sphere_mat := g.material(shininess = 1000, specular = 1);
    small_sphere1 := s.sphere(&sb, m.translate(m.scaling(.2, .2, .2), 0, .2, -1), small_sphere_mat);
    small_sphere2 := s.sphere(&sb, m.translate(m.scaling(.2, .2, .2), .8, .2, .2), g.material(small_sphere_mat, g.color(.8, .2, .2)));

    shapes := []^s.Shape { floor, left_wall, right_wall, middle_sphere, right_sphere, left_sphere, small_sphere1, small_sphere2 };

    lights := []g.Point_Light {
        g.point_light(m.point(-10, 10, -10), g.color(.8, .8, .8)),
        g.point_light(m.point(10, 10, -10), g.color(.3, .1, .1)),
    };

    world := w.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := w.camera(c.width, c.height, PI / 3, view_transform)

    w.render(&c, &camera, &world);

    ppm := g.ppm_from_canvas(c);
    defer delete(ppm);

    ok := g.ppm_write_to_file("images/putting_it_together_ch08.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

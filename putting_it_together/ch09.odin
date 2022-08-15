package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH09 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 9");

    floor_mat := rt.material(color=rt.color(0.9, 0.9, 0.9), specular=0);
    floor := rt.plane(floor_mat);

    wall_mat := rt.material(color=rt.color(.07, .07, .07), ambient=.4, specular=0);
    wall1 := rt.plane(m.translation(0, 0, 0.05) * m.rotation_x(PI / 2), wall_mat);
    wall_mat.color = rt.color(.2, .3, .8);
    wall_mat.ambient = .4;
    wall_mat.specular = .2;
    wall2 := rt.plane(m.translation(-1, 0, -0.5) * m.rotation_y(PI / 3.2) * m.rotation_z(PI / 2), wall_mat);

    sphere_mat := rt.material(diffuse=0.7, specular=0.3, reflective=.3);
    middle_sphere := rt.sphere(m.translation(-0.5, 1, 0.5), rt.material(sphere_mat, rt.color(0.1, 1, 0.5)));
    right_sphere := rt.sphere(m.translate(m.scaling(0.5, 0.5, 0.5), 1.5, 0.5, -0.5), rt.material(sphere_mat, rt.color(0.5, 1, 0.1)));
    left_sphere := rt.sphere(m.translate(m.scaling(0.33, 0.33, 0.33), -1.5, 0.33, -0.75), rt.material(sphere_mat, rt.color(1, 0.8, 0.1)));

    small_sphere_mat := rt.material(shininess = 1000, specular = 1, reflective = .4);
    small_sphere1 := rt.sphere(m.translate(m.scaling(.2, .2, .2), 0, .2, -1), small_sphere_mat);
    small_sphere2 := rt.sphere(m.translate(m.scaling(.25, .25, .25), .8, .2, .2), rt.material(small_sphere_mat, rt.color(.8, .2, .2)));

    shapes := []^rt.Shape { &floor, &wall1, &wall2, &middle_sphere, &right_sphere, &left_sphere, &small_sphere1, &small_sphere2 };

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

    ok := rt.ppm_write_to_file("images/putting_it_together_ch09.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

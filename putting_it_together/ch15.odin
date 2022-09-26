package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:fmt"
import "core:math"

CH15_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 15.1");

    floor := rt.plane();

    t1 := rt.triangle(m.point(0, 0.5, 0), m.point(-0.5, 0, 0), m.point(0.5, 0, 0));

    free_group_recursive :: proc(g: ^rt.Group) {
        for c in g.shapes {

            // Only group has this function
            if c.vtable.child_count != nil {
                free_group_recursive(transmute(^rt.Group)c);
            }

            free(c);
        }
    }

    tetrahedon :: proc() -> ^rt.Group {
        tetra := new(rt.Group);
        tetra^ = rt.group();

        p1 := m.point(0, 0, 0.5);
        p2 := m.point(-0.5, 0, 0);
        p3 := m.point(0.5, 0, 0);
        p4 := m.point(0, 0.5, 0);

        // invsqrt2 := 1.0 / math.sqrt(m.real(2));

        // p1 := m.point(1, -invsqrt2, 0);
        // p2 := m.point(-1, -invsqrt2, 0);
        // p3 := m.point(0, invsqrt2, 1);
        // p4 := m.point(0, invsqrt2, -1);

        t1 := new(rt.Triangle);
        t1^ = rt.triangle(p1, p2, p3);
        rt.group_add_child(tetra, t1);

        t2 := new(rt.Triangle);
        t2^ = rt.triangle(p1, p2, p4);
        t2.material.color = rt.color(1, 0, 0);
        rt.group_add_child(tetra, t2);

        t3 := new(rt.Triangle);
        t3^ = rt.triangle(p1, p3, p4);
        t3.material.color = rt.color(0, 1, 0);
        rt.group_add_child(tetra, t3);

        t4 := new(rt.Triangle);
        t4^ = rt.triangle(p2, p3, p4);
        t4.material.color = rt.color(0, 0, 1);
        rt.group_add_child(tetra, t4);

        return tetra;
    }

    all_tetras := rt.group();
    defer free_group_recursive(&all_tetras);

    rotations := [3]m.real {
        0,
        0, 0,
        // 2 * PI / 3,
        // 2 * PI / 3 * 2,
    };

    for i in 0..<3 {

        tetra := tetrahedon();
        rot := m.real(i) * (2 * PI / 5);
        tf := m.translation(m.real(i - 2), 0, 0) * m.scaling(0.5, 0.5, 0.5) * m.rotation_y(rotations[i]);
        rt.set_transform(tetra, tf);

        rt.group_add_child(&all_tetras, tetra);
    }

    shapes := []^rt.Shape {
        &all_tetras,
        // &floor,
    };

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 1.5, -5), m.point(0, 1, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch15.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

CH15_2 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 15.2");

    check_pat := rt.checkers_pattern(rt.color(0.9, 0.9, 0.9), rt.color(0.8, 0.8, 0.8));
    floor := rt.plane();
    floor.material.pattern = &check_pat;
    wall := rt.plane(m.translation(0, 0, 10) * m.rotation_x(PI / 2));
    wall.material.pattern = &check_pat;

    obj_test, obj_ok := rt.parse_obj_file("tests/teapot.obj", false);
    if !obj_ok {
        panic("Parsing obj file failed...");
    }
    defer rt.free_parsed_obj_file(&obj_test);

    fmt.printf("obj group count: %v\n", len(obj_test.groups));

    obj_material := rt.material(color=rt.color_u8(255, 102, 102));
    obj_group := rt.obj_to_group(&obj_test, obj_material);
    defer { rt.delete_group(obj_group); free(obj_group); }

    rt.set_transform(obj_group, m.translation(0, .6, -2) * m.scaling(0.1, 0.1, 0.1) * m.rotation_x(-PI / 2));

    shapes := []^rt.Shape {
        &floor, &wall,
        obj_group,
    };

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 3, -7), m.point(0, 0, 0), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch15.2.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

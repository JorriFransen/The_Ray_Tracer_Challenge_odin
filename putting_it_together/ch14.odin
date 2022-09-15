package putting_it_together

import rt "raytracer:."
import m "raytracer:math"

import "core:math/rand"
import "core:math"
import "core:fmt";

CH14_1 :: proc(c: rt.Canvas) {
    c := c;
    fmt.println("Putting it together for chapter 14.1");

    materials := [?]rt.Material {
        rt.material(color=rt.color(0, 0, 0.2), ambient=0, diffuse=0.4, specular=0.9, shininess=300, reflective=0.9, transparency=0.9, refractive_index=1.5),
        rt.material(color=rt.color(0, 0.2, 0), ambient=0, diffuse=0.4, specular=0.9, shininess=300, reflective=0.9, transparency=0.9, refractive_index=1.5),
        rt.material(color=rt.color(0.2, 0, 0), ambient=0.35, diffuse=0.3, specular=0.8, shininess=200, reflective=0.3, transparency=0, refractive_index=1),
        rt.material(color=rt.color(0, 0, 0.2), ambient=0.5, diffuse=0.3, specular=0.8, shininess=5, reflective=0.1, transparency=0, refractive_index=1),
    };

    _spheres : [dynamic]rt.Shape;

    rand.set_global_seed(1);

    placed := 0;

    min_dist : m.real = 0.1;

    // Without groups:
    //
    //           100 placement iterations (75 placed)
    // 1,043,592,784 Intersection tests
    //    38,206,970 Hits (3.66%)
    //
    //          2000 placement iterations (327 placed)
    // 8,270,677,440 Intersection tests
    //    99,956,049 Hits (1.21%)


    // With groups
    //           100 placement iterations (75 placed)
    // 322,277,995 Intersections
    //  38,206,970 Hits (11.86%)
    //
    //          2000 placement iterations (327 placed)

    DO_GROUPS :: true;

    minx, maxx : m.real = -7.5, 7.5;
    minz, maxz : m.real = -1, 20;
    minscale, maxscale := 0.15, 0.6;

    when DO_GROUPS {
        // group := rt.group();
        // defer rt.delete_group(&group);

        groups : [16]rt.Group;
        for i := 0; i < len(groups); i += 1 {
            groups[i] = rt.group();
        }

        defer for g in &groups do rt.delete_group(&g);

    }

    for i in 0..<2000 {

        x := rand.float64_range(minx, maxx);
        z := rand.float64_range(minz, maxz);
        scale := rand.float64_range(minscale, maxscale);
        mat_idx := rand.uint64() % len(materials);

        transform := m.translation(x, scale, z) * m.scaling(scale, scale, scale);

        hit := false;

        for s in &_spheres {
            my_point := transform * m.point(0, 0, 0);
            other_transform := m.matrix_inverse(s.inverse_transform);
            other_point := m.matrix4_mul_tuple(other_transform, m.point(0, 0, 0));

            d := m.magnitude(m.sub(my_point, other_point));

            other_scale := other_transform[0, 0];

            // Assuming uniform scale
            if d < (abs(scale + other_scale) + min_dist) {
                hit = true;
                break;
            }
        }

        if !hit {
            sphere := rt.sphere(transform, materials[mat_idx]);
            append(&_spheres, sphere);
            placed += 1;
        }
    }

    fmt.printf("Placed %v spheres\n", placed);

    // Always include the floor
    root_shape_count := 1;
    when DO_GROUPS {
        root_shape_count += len(groups);
    } else {
        root_shape_count += placed
    }

    shapes := make([]^rt.Shape, root_shape_count);
    defer delete(shapes);

    floor := rt.plane();
    shapes[0] = &floor;

    when DO_GROUPS {

        for g, i in &groups {
            shapes[i + 1] = &g;
        }

        group_width := abs(minx - maxx) / 4.0;
        group_height := abs(minz - maxz) / 4.0;

        for s in &_spheres {
            sphere_tf := m.matrix_inverse(s.inverse_transform);
            sphere_pos := m.matrix4_mul_tuple(sphere_tf, m.point(0, 0, 0));

            group_x := int(math.floor((sphere_pos.x - minx) / group_width));
            group_z := int(math.floor((sphere_pos.z - minz) / group_height));

            assert(group_x >= 0 && group_x < 4);
            assert(group_z >= 0 && group_z < 4);

            rt.group_add_child(&groups[group_x + 4 * group_z], &s);
        }

    } else {
        for i := 0; i < len(_spheres); i += 1 {
            shapes[i + 1] = &_spheres[i];
        }
    }

    // when DO_GROUPS {

    //     total_sphere_count := 0;

    //     for g in &groups {
    //         fmt.println(g->bounds());
    //         fmt.println(len(g.shapes));
    //         total_sphere_count += len(g.shapes);
    //     }

    //     fmt.println(total_sphere_count);
    // }

    lights := []rt.Point_Light {
        rt.point_light(m.point(-10, 10, -10), rt.WHITE),
    };

    world := rt.world(shapes, lights);

    view_transform := m.view_transform(m.point(0, 3, -4), m.point(0, 0, 4), m.vector(0, 1, 0));
    camera := rt.camera(c.width, c.height, PI / 3, view_transform)

    rt.render(&c, &camera, &world);

    fmt.printf("%12d Intersections\n", rt.total_xs_test);
    fmt.printf("%12d Hits\n", rt.total_hit);

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch14.1.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }
}

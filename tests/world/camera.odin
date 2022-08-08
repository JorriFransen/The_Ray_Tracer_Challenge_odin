package tests_world

import "core:math"

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

camera_suite := r.Test_Suite {
    name = "Camera/",
    tests = {
        r.test("Construction", C_Construction),
        r.test("Horizontal_Canvas_Pixel_Size", HC_Pixel_Size),
        r.test("Vertical_Canvas_Pixel_Size", VC_Pixel_Size),
        r.test("Ray_Center_Canvas", Ray_Center_Canvas),
        r.test("Ray_Corner_Canvas", Ray_Corner_Canvas),
        r.test("Ray_Transformed_Cam", Ray_Transformed_Cam),
        r.test("Render_Default_World", Render_Default_World),
    },
}


@test
C_Construction :: proc(t: ^r.Test_Context) {

    hsize := 160;
    vsize := 120;
    fov := PI / 2;

    c := rt.camera(hsize, vsize, fov);

    expect(t, c.size.x == 160);
    expect(t, c.size.y == 120);
    expect(t, c.fov == PI / 2);
    expect(t, eq(c.inverse_transform, m.matrix4_identity));
}

@test
HC_Pixel_Size :: proc(t: ^r.Test_Context) {

    c := rt.camera(200, 125, PI / 2);

    expect(t, eq(c.pixel_size, 0.01));
}

@test
VC_Pixel_Size :: proc(t: ^r.Test_Context) {

    c := rt.camera(125, 200, PI / 2);

    expect(t, eq(c.pixel_size, 0.01));
}

@test
Ray_Center_Canvas:: proc(t: ^r.Test_Context) {

    c := rt.camera(201, 101, PI / 2);

    ray := rt.camera_ray_for_pixel(&c, 100, 50);

    expect(t, eq(ray.origin, m.point(0, 0, 0)));
    expect(t, eq(ray.direction, m.vector(0, 0, -1)));
}

@test
Ray_Corner_Canvas :: proc(t: ^r.Test_Context) {

    c := rt.camera(201, 101, PI / 2);

    ray := rt.camera_ray_for_pixel(&c, 0, 0);

    expect(t, eq(ray.origin, m.point(0, 0, 0)));
    expect(t, eq(ray.direction, m.vector(0.66519, 0.33259, -0.66851)));
}

@test
Ray_Transformed_Cam :: proc(t: ^r.Test_Context) {

    tf := m.rotation_y( PI / 4) * m.translation(0, -2, 5)
    c := rt.camera(201, 101, PI / 2, tf);
    ray := rt.camera_ray_for_pixel(&c, 100, 50);

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;

    expect(t, eq(ray.origin, m.point(0, 2, -5)));
    expect(t, eq(ray.direction, m.vector(sqrt2_over_2, 0, -sqrt2_over_2)));

}

@test
Render_Default_World :: proc(t: ^r.Test_Context) {
    tc := transmute(^r.Test_Context)t;

    sb : rt.Shapes(2);

    world := default_world(&sb);
    defer destroy_default_world(world);

    from := m.point(0, 0, -5);
    to := m.point(0, 0, 0);
    up := m.vector(0, 1, 0);
    tf := m.view_transform(from, to, up);
    c := rt.camera(11, 11, PI / 2, tf);

    {
        image := rt.render(&c, world);
        defer rt.canvas_destroy(&image);

        old_fail_count := tc.assert_fail_count;

        expect(t, image.width == 11);
        expect(t, image.height == 11);

        if tc.assert_fail_count != old_fail_count do return;

        expect(t, eq(rt.canvas_get_pixel(image, 5, 5), rt.color(0.38066, 0.47583, 0.2855)));
    }

    {
        image := rt.canvas(11, 11);
        defer rt.canvas_destroy(&image);
        rt.render(&image, &c, world);

        old_fail_count := tc.assert_fail_count;

        expect(t, image.width == 11);
        expect(t, image.height == 11);

        if tc.assert_fail_count != old_fail_count do return;

        expect(t, eq(rt.canvas_get_pixel(image, 5, 5), rt.color(0.38066, 0.47583, 0.2855)));
    }
}

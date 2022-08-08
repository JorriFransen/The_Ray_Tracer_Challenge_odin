package putting_it_together;

import rt "raytracer:."
import m "raytracer:math"

import "core:math"
import "core:fmt";

CH06 :: proc(c: rt.Canvas) {
    fmt.println("Putting it together for chapter 6");

    assert(c.width == c.height);

    sb : rt.Shapes(1);

    ray_origin := m.point(0, 0, -5);
    wall_z : m.real = 10;

    wall_size := calculate_wall_size(ray_origin, wall_z);

    canvas_pixels := c.width;
    pixel_size := wall_size / m.real(canvas_pixels);
    half_wall_size := wall_size / 2;

    mat := rt.material(rt.color(1, 0.2, 1));
    shape := rt.sphere(&sb, mat);
    // shape := m.sphere(m.scaling(0.5, 1, 1));
    // shape := m.sphere(m.rotation_z(PI / 4) * m.scaling(0.5, 1, 1));
    // shape := m.sphere(m.shearing(1, 0, 0, 0, 0, 0) * m.scaling(0.5, 1, 1));

    light := rt.point_light(m.point(-10, 10, -10), rt.color(1, 1, 1));

    for y in 0..<canvas_pixels {
        world_y := half_wall_size - pixel_size * m.real(y);

        for x in 0..<canvas_pixels {
            world_x := -half_wall_size + pixel_size * m.real(x);

            position := m.point(world_x, world_y, wall_z);

            r := m.ray(ray_origin, m.normalize(m.sub(position, ray_origin)));
            xs, did_intersect := rt.intersects(shape, r).?;

            if !did_intersect do continue;

            if hit, ok : = rt.hit(xs[:]).?; ok {

                hitpoint := m.ray_position(r, hit.t);
                hitnormal := rt.normal_at(hit.object, hitpoint);
                eye_v := m.negate(r.direction);


                color := rt.lighting(hit.object.material, light, hitpoint, eye_v, hitnormal);

                rt.canvas_write_pixel(c, x, y, color);
            }

        }
    }

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch06.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

@(private="file")
calculate_wall_size :: proc(o: m.Point, wall_z: m.real) -> m.real {

    // https://www.desmos.com/calculator/u5mhu61div

    sy : m.real = 1;
    if o.x < 0 {
        sy = -1;
    }

    a := (sy - o.y) / -o.z; // (sy - ray_origin.y) / (sx - ray_origin.y) but sx is always zero
    b := sy; // (sy - a * sx) but sx is always zero
    iy : m.real = a * wall_z + b;

    return  abs(iy) * 2 + abs(sy);
}

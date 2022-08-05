package putting_it_together;

import m "raytracer:math"
import g "raytracer:graphics"
import s "raytracer:shapes"

import "core:math"
import "core:fmt";

CH06 :: proc(c: g.Canvas) {
    fmt.println("Putting it together for chapter 6");

    assert(c.width == c.height);

    ray_origin := m.point(0, 0, -5);
    wall_z : m.Tuple_Element_Type = 10;

    wall_size := calculate_wall_size(ray_origin, wall_z);

    canvas_pixels := c.width;
    pixel_size := wall_size / m.Tuple_Element_Type(canvas_pixels);
    half_wall_size := wall_size / 2;

    mat := g.material(g.color(1, 0.2, 1));
    shape := s.sphere(mat);
    // shape := m.sphere(m.scaling(0.5, 1, 1));
    // shape := m.sphere(m.rotation_z(PI / 4) * m.scaling(0.5, 1, 1));
    // shape := m.sphere(m.shearing(1, 0, 0, 0, 0, 0) * m.scaling(0.5, 1, 1));

    light := g.point_light(m.point(-10, 10, -10), g.color(1, 1, 1));

    for y in 0..<canvas_pixels {
        world_y := half_wall_size - pixel_size * m.Tuple_Element_Type(y);

        for x in 0..<canvas_pixels {
            world_x := -half_wall_size + pixel_size * m.Tuple_Element_Type(x);

            position := m.point(world_x, world_y, wall_z);

            r := m.ray(ray_origin, m.normalize(m.sub(position, ray_origin)));
            xs, did_intersect := s.intersects(shape, r).?;

            if !did_intersect do continue;

            if hit, ok : = s.hit(xs[:]).?; ok {

                hitpoint := m.ray_position(r, hit.t);
                hitnormal := s.shape_normal_at(&hit.object, hitpoint);
                eye_v := m.negate(r.direction);

                color := g.lighting(hit.object.material, light, hitpoint, eye_v, hitnormal);

                g.canvas_write_pixel(c, x, y, color);
            }

        }
    }

    ppm := g.ppm_from_canvas(c);
    defer delete(ppm);

    ok := g.ppm_write_to_file("images/putting_it_together_ch06.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

@(private="file")
calculate_wall_size :: proc(o: m.Point, wall_z: m.Tuple_Element_Type) -> m.Tuple_Element_Type {

    // https://www.desmos.com/calculator/u5mhu61div

    sy : m.Tuple_Element_Type = 1;
    if o.x < 0 {
        sy = -1;
    }

    a := (sy - o.y) / -o.z; // (sy - ray_origin.y) / (sx - ray_origin.y) but sx is always zero
    b := sy; // (sy - a * sx) but sx is always zero
    iy : m.Tuple_Element_Type = a * wall_z + b;

    return  abs(iy) * 2 + abs(sy);
}

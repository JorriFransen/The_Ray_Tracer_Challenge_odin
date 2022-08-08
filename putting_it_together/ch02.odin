package putting_it_together

import "core:fmt"
import "core:math"
import "core:os"

import rt "raytracer:."
import rm "raytracer:math"

CH02 :: proc (c: rt.Canvas) {
    fmt.println("Putting it together for chapter 2");

    start := rm.point(0, 1, 0);
    velocity := rt.mul(rm.normalize(rm.vector(1, 1.8, 0)), 11.25);
    p := Projectile { start, velocity };

    gravity := rm.vector(0, -0.1, 0);
    wind := rm.vector(-0.02, 0, 0);
    e := Environment { gravity, wind };

    write_projectile_to_canvas(c, p.position);

    for p.position.y > 0 {
        p = tick(&e, p);
        write_projectile_to_canvas(c, p.position);
    }

    ppm := rt.ppm_from_canvas(c);
    defer delete(ppm);

    ok := rt.ppm_write_to_file("images/putting_it_together_ch02.ppm", ppm)
    if !ok {
        panic("Failed to write ppm file...");
    }
}

PROJECTILE_COLOR :: rt.Color { 1, 0, 0, 0 };

write_projectile_to_canvas :: proc(c: rt.Canvas, p: rm.Point) {

    x := int(math.ceil(p.x));
    y := int(math.ceil(p.y));

    write_pixel_to_canvas(c, x, y);
    write_pixel_to_canvas(c, x + 1, y);
    write_pixel_to_canvas(c, x, y + 1);
    write_pixel_to_canvas(c, x + 1, y + 1);

}

write_pixel_to_canvas :: proc(c: rt.Canvas, x, y: int) {

    in_range := (x >= 0 && x < c.width) && (y >= 0 && y < c.height);

    inverted_y := (c.height - 1) - y;

    if in_range {
        rt.canvas_write_pixel(c, x, inverted_y, PROJECTILE_COLOR);
    }
}

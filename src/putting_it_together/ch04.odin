//+private file
package putting_it_together

import "core:fmt"
import "core:math"

import g "raytracer:graphics"
import m "raytracer:math"

PI :: math.PI;

canvas_transform : m.Matrix4;
hour_size : int;
minute_size : int;

@private
CH04 :: proc(c: g.Canvas) {
    fmt.println("Putting it together for chapter 4");

    assert(c.width == c.height);

    canvas_size := f32(c.width);
    clock_size := canvas_size / 8.0 * 3.0;

    canvas_transform = m.translate(m.scaling(clock_size, -clock_size, 1), canvas_size / 2, canvas_size / 2, 0);

    hour_size = int(canvas_size / 100.0);
    minute_size = int(canvas_size / 250.0);

    zero_hour := m.point(0, 1, 0);

    for i in 0..<12 {

        fi := m.Tuple_Element_Type(i);
        p := m.rotate_z(zero_hour, -fi * PI / 6.0);

        color := g.WHITE;
        if i % 3 == 0 {
            color = g.RED;
        }

        write_rect(c, p, color, hour_size);
    }

    zero_min := m.point(0, 0.99, 0);

    for i in 0..<60 {

        fi := m.Tuple_Element_Type(i);
        p := m.rotate_z(zero_min, -fi * PI / 30.0);

        color := g.WHITE;
        if i % 5 == 0 && i % 15 != 0 {
            color = g.RED;
        }

        write_rect(c, p, color, minute_size);
    }

    ppm := g.ppm_from_canvas(c);
    defer delete(ppm);

    ok := g.ppm_write_to_file("images/putting_it_together_ch04.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

write_rect :: proc(c: g.Canvas, p: m.Point, color: g.Color, dim: int) {

    dim := m.Tuple_Element_Type(dim);
    p := canvas_transform * p;

    for y := p.y - dim; y < p.y + dim; y += 1 {
        for x := p.x - dim; x < p.x + dim; x += 1 {
            write_pixel(c, m.point(x, y, 0), color);
        }
    }
}

write_pixel :: proc(c: g.Canvas, p: m.Point, color: g.Color) {
    if p.x >= 0 && int(p.x) < c.width && p.y >= 0 && int(p.y) < c.height {
        g.canvas_write_pixel(c, p, color);
    }
}

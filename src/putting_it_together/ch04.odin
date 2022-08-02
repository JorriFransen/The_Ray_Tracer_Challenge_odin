package putting_it_together

import "core:fmt"
import "core:math"

import g "raytracer:graphics"
import m "raytracer:math"

PI :: math.PI;

CANVAS_SIZE :: 1500;
CLOCK_SIZE :: CANVAS_SIZE / 8.0 * 3.0;

canvas_transform := m.translation(CANVAS_SIZE / 2, CANVAS_SIZE / 2, 0) * m.scaling(CLOCK_SIZE, -CLOCK_SIZE, 1);

putting_it_together_CH04 :: proc() {


    c := g.canvas(CANVAS_SIZE, CANVAS_SIZE);
    defer g.canvas_destroy(&c);

    zero_hour := m.point(0, 1, 0);

    for i in 0..<12 {

        fi := m.Tuple_Element_Type(i);
        p := m.rotation_z(-fi * PI / 6.0) * zero_hour;

        color := g.WHITE;
        if i % 3 == 0 {
            color = g.RED;
        }

        write_hour(c, p, color);
    }

    zero_min := m.point(0, 0.99, 0);

    for i in 0..<60 {

        fi := m.Tuple_Element_Type(i);
        p := m.rotation_z(-fi * PI / 30.0) * zero_min;

        color := g.WHITE;
        if i % 5 == 0 && i % 15 != 0 {
            color = g.RED;
        }

        write_minute(c, p, color);
    }

    ppm := g.ppm_from_canvas(c);
    defer delete(ppm);

    ok := g.ppm_write_to_file("images/putting_it_together_ch03.ppm", ppm);
    if !ok {
        panic("Failed to write ppm file...");
    }

}

write_hour :: proc(c: g.Canvas, p: m.Point, color: g.Color) {
    DIM :: CANVAS_SIZE / 100;
    #assert(DIM > 0);

    write_rect(c, p, color, DIM);
}

write_minute :: proc(c: g.Canvas, p: m.Point, color: g.Color) {
    DIM :: CANVAS_SIZE / 250;
    #assert(DIM > 0);

    write_rect(c, p, color, DIM);
}

write_rect :: proc(c: g.Canvas, p: m.Point, color: g.Color, dim: int) {

    dim := m.Tuple_Element_Type(dim);
    p := m.mul(canvas_transform, p);

    for y := p.y - dim; y < p.y + dim; y += 1 {
        for x := p.x - dim; x < p.x + dim; x += 1 {
            g.canvas_write_pixel(c, m.point(x, y, 0), color);
        }
    }
}

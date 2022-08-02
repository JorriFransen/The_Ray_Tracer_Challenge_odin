package graphics;

import m "../math"

Canvas :: struct {
    width, height: int,

    pixels: []Color `Backing memory for pixels`,
}

canvas :: proc(width, height: int, allocator := context.allocator) -> Canvas {
    return Canvas {
        width, height,
        make([]Color, width * height, allocator),
    };
}

canvas_destroy :: proc(c: ^Canvas) {
    c.width = 0;
    c.height = 0;
    delete(c.pixels);
}

canvas_clear :: proc(c: Canvas, color: Color) {
    for _,i in c.pixels {
        c.pixels[i] = color;
    }
}

canvas_write_pixel_xy :: proc(c: Canvas, x, y: int, pixel: Color) {
    assert(x >= 0 && x < c.width);
    assert(y >= 0 && y < c.height);

    c.pixels[x + y * c.width] = pixel;
}

canvas_write_pixel_p :: proc(c: Canvas, p: m.Point, pixel: Color) {
    canvas_write_pixel_xy(c, int(p.x), int(p.y), pixel);
}

canvas_write_pixel :: proc {
    canvas_write_pixel_xy,
    canvas_write_pixel_p,
}

canvas_get_pixel :: proc(c: Canvas, x, y: int) -> Color {
    assert(x >= 0 && x < c.width);
    assert(y >= 0 && y < c.height);

    return c.pixels[x + y * c.width];
}


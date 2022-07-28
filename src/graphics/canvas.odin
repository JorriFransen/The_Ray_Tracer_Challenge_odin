
package graphics;

import "core:fmt"
import "core:mem"
import "core:strings"

Canvas :: struct {
    width, height: uint,

    pixels: []Color,
}

canvas :: proc(width, height: uint, allocator := context.allocator) -> Canvas {
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

write_pixel :: proc(c: Canvas, x, y: uint, pixel: Color) {
    assert(x < c.width);
    assert(y < c.height);

    c.pixels[x + y * c.width] = pixel;
}

pixel_at :: proc(c: Canvas, x, y: uint) -> Color {
    assert(x < c.width);
    assert(y < c.height);

    return c.pixels[x + y * c.width];
}

canvas_to_ppm :: proc(c: Canvas, allocator := context.allocator) -> string {

    sb := strings.builder_make_none(allocator);
    defer strings.builder_destroy(&sb);

    fmt.sbprintln(&sb, "P3");
    fmt.sbprintf(&sb, "%d %d\n", c.width, c.height);
    fmt.sbprintln(&sb, "255");

    return strings.clone(strings.to_string(sb), allocator);
}

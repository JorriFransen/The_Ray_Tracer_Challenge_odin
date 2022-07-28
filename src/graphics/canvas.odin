
package graphics;

import "core:fmt"
import "core:strings"

Canvas :: struct {
    width, height: uint,

    pixels: []Color,
}

canvas :: proc(width, height: uint) -> Canvas {
    return Canvas {
        width, height,
        make([]Color, width * height),
    };
}

canvas_destroy :: proc(c: ^Canvas) {
    delete(c.pixels);
    c.width = 0;
    c.height = 0;
    c.pixels = nil;
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

canvas_to_ppm :: proc(c: Canvas) -> string {
    sb := strings.builder_make_none();
    defer strings.builder_destroy(&sb);

    fmt.sbprintf(&sb, "P3\n%d %d\n255", c.width, c.height);

    return strings.clone(strings.to_string(sb));
}

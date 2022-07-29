
package graphics;

import "core:fmt"
import "core:intrinsics"
import "core:mem"
import "core:strings"
import m "core:math"
import ml"core:math/linalg"

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

canvas_clear :: proc(c: Canvas, color: Color) {
    for _,i in c.pixels {
        c.pixels[i] = color;
    }
}

canvas_write_pixel :: proc(c: Canvas, x, y: uint, pixel: Color) {
    assert(x < c.width);
    assert(y < c.height);

    c.pixels[x + y * c.width] = pixel;
}

canvas_get_pixel :: proc(c: Canvas, x, y: uint) -> Color {
    assert(x < c.width);
    assert(y < c.height);

    return c.pixels[x + y * c.width];
}

canvas_to_ppm :: proc(c: Canvas, allocator := context.allocator) -> string {

    _sb := strings.builder_make_none(allocator);
    sb := &_sb;
    defer strings.builder_destroy(sb);

    fmt.sbprintln(sb, "P3");
    fmt.sbprintf(sb, "%d %d\n", c.width, c.height);
    fmt.sbprintln(sb, "255");

    pixel_count := c.width * c.height;

    line_start := len(sb.buf);

    for i : uint = 0; i < pixel_count; i += 1 {

        p := c.pixels[i];

        last_on_line := (i + 1) % c.width == 0;

        ppm_write_element(sb, p.r, &line_start, false);
        ppm_write_element(sb, p.g, &line_start, false);
        ppm_write_element(sb, p.b, &line_start, last_on_line);

        if last_on_line {
            fmt.sbprint(sb, "\n");
            line_start = len(sb.buf);
        }
    }

    return strings.clone(strings.to_string(sb^), allocator);
}

@private
ppm_write_element :: proc(sb: ^strings.Builder, e: $T, line_start: ^int, last_on_line: bool) where intrinsics.type_is_float(T) {

    line_len := len(sb.buf) - line_start^;
    if (line_len + 3 >= 70) {
        fmt.sbprint(sb, "\n");
        line_start^ = len(sb.buf);
    }

    real_value := ml.clamp(e, 0.0, 1.0)
    int_value := int(m.ceil(255 * real_value));
    fmt.sbprintf(sb, "%v", int_value);

    line_len = len(sb.buf) - line_start^;
    if !last_on_line && line_len + 4 < 70 {
        fmt.sbprint(sb, " ");
    }
}

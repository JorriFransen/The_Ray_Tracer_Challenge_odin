package graphics

import "core:fmt"
import "core:intrinsics"
import "core:mem"
import "core:strings"
import "core:os"
import m "core:math"
import ml"core:math/linalg"

PPM_MAGIC :: "P3"
PPM_ELEMENT_RESOLUTION :: 255;
PPM_MAX_LINE_LENGTH :: 70;

ppm_from_canvas :: proc(c: Canvas, allocator := context.allocator) -> string {

    _sb := strings.builder_make_none(allocator);
    sb := &_sb;
    defer strings.builder_destroy(sb);

    // Header
    fmt.sbprintf(sb, "%s\n", PPM_MAGIC);
    fmt.sbprintf(sb, "%d %d\n", c.width, c.height);
    fmt.sbprintf(sb, "%d\n", PPM_ELEMENT_RESOLUTION);


    // Body
    pixel_count := c.width * c.height;
    line_start := len(sb.buf);

    for i := 0; i < pixel_count; i += 1 {

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

ppm_write_to_file :: proc(file_name, ppm: string) -> (success: bool)  {

    assert(ppm[:2] == PPM_MAGIC);

    fmt.printf("Writing ppm to file: '%v'\n", file_name);

    return os.write_entire_file(file_name, transmute([]u8)ppm);
}

@private
ppm_write_element :: proc(sb: ^strings.Builder, e: $T, line_start: ^int, last_on_line: bool) where intrinsics.type_is_float(T) {

    line_len := len(sb.buf) - line_start^;
    if line_len + 3 >= PPM_MAX_LINE_LENGTH {
        fmt.sbprint(sb, "\n");
        line_start^ = len(sb.buf);
    }

    real_value := ml.clamp(e, 0.0, 1.0)
    int_value := int(m.ceil(PPM_ELEMENT_RESOLUTION * real_value));
    assert(int_value >= 0);
    assert(int_value <= 255);
    fmt.sbprintf(sb, "%v", int_value);

    line_len = len(sb.buf) - line_start^;
    if !last_on_line && line_len + 1 < PPM_MAX_LINE_LENGTH {
        fmt.sbprint(sb, " ");
    }
}

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

PPM_Print_State :: struct {
    sb: ^strings.Builder,
    current_line_length: int,
}

ppm_from_canvas :: proc(c: Canvas, allocator := context.allocator) -> string {

    _sb := strings.builder_make_none(allocator);
    sb := &_sb;
    defer strings.builder_destroy(sb);

    // Header
    fmt.sbprintf(sb, "%s\n", PPM_MAGIC);
    fmt.sbprintf(sb, "%d %d\n", c.width, c.height);
    fmt.sbprintf(sb, "%d\n", PPM_ELEMENT_RESOLUTION);


    // Body
    state := PPM_Print_State { sb, 0 };

    for y in 0..<c.height {

        for x in 0..<c.width {

            p := canvas_get_pixel(c, x, y);

            append_element(&state, p.r);
            append_element(&state, p.g);
            append_element(&state, p.b);
        }

        fmt.sbprint(state.sb, '\n');
        state.current_line_length = 0;
    }

    return strings.clone(strings.to_string(sb^), allocator);
}

ppm_write_to_file :: proc(file_name, ppm: string) -> (success: bool)  {

    assert(ppm[:2] == PPM_MAGIC);

    fmt.printf("Writing ppm to file: '%v'\n", file_name);

    return os.write_entire_file(file_name, transmute([]u8)ppm);
}

@(private="file")
append_element :: #force_inline proc(state: ^PPM_Print_State, e: $T) where intrinsics.type_is_float(T) {

    real_value := ml.clamp(e, 0.0, 1.0)
    int_value := int(m.ceil(PPM_ELEMENT_RESOLUTION * real_value));
    assert(int_value >= 0);
    assert(int_value <= 255);

    // leading space included
    length := 2;
    if int_value > 9 do length = 3;
    if int_value > 99 do length = 4;

    format := "%v";

    if state.current_line_length + length > PPM_MAX_LINE_LENGTH {

        fmt.sbprint(state.sb, '\n');
        state.current_line_length = 0;
        length -= 1; // don't print leading space

    } else if state.current_line_length == 0 {

        // Newline from outside this function
        length -= 1; // don't print leading space

    } else {
        format = " %v";
    }

    fmt.sbprintf(state.sb, format, int_value);
    state.current_line_length += length;
}

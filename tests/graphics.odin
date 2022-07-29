package tests;

import "core:fmt"
import "core:testing"
import "core:strings"

import g "../src/graphics"
import m "../src/rtmath"


all_graphics_tests :: proc(t: ^testing.T) {
    Color_Constructor(t);
    Color_Layout_Matches_Tuple(t);

    Color_Add(t);
    Color_Sub(t);
    Color_Mul_Scalar(t);
    Color_Mul(t);

    Canvas_Constructor(t);
    Canvas_Write_Pixel(t);
    Canvas_PPM_Header(t);
    Canvas_PPM_Pixel_Data_Construction(t);
    Canvas_Clear(t);
    Canvas_PPM_Line_Splitting(t);
    Canvas_PPM_Ends_With_Newline(t);
}

@test
Color_Constructor :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c := g.color(-0.5, 0.4, 1.7);

    expected_r :: -0.5;
    expected_g :: 0.4;
    expected_b :: 1.7;

    expect(t, c.r == expected_r);
    expect(t, c.g == expected_g);
    expect(t, c.b == expected_b);

}

@test
Color_Layout_Matches_Tuple :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c := g.color(-0.5, 0.4, 1.7);

    expected := m.tuple(-0.5, 0.4, 1.7, 0.0);

    expect(t, transmute(m.Tuple)c == expected);
    expect(t, c == transmute(g.Color)expected);
    expect(t, m.tuple(c.r, c.g, c.b, 0.0) == expected);
}

@test
Color_Add :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c1 := g.color(0.9, 0.6, 0.75);
    c2 := g.color(0.7, 0.1, 0.25);

    expected := g.color(1.6, 0.7, 1.0);
    result := g.add(c1, c2);

    expect(t, g.eq(result, expected));
}

@test
Color_Sub :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c1 := g.color(0.9, 0.6, 0.75);
    c2 := g.color(0.7, 0.1, 0.25);

    expected := g.color(0.2, 0.5, 0.5);
    result := g.sub(c1, c2);

    expect(t, g.eq(result, expected));
}

@test
Color_Mul_Scalar :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c := g.color(0.2, 0.3, 0.4);

    expected := g.color(0.4, 0.6, 0.8);
    result := g.mul(c, 2);

    expect(t, g.eq(result, expected));
}

@test
Color_Mul :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c1 := g.color(1.0, 0.2, 0.4);
    c2 := g.color(0.9, 1, 0.1);

    expected := g.color(0.9, 0.2, 0.04);
    result := g.mul(c1, c2);

    expect(t, g.eq(result, expected));
}

@test
Canvas_Constructor :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    width := 10;
    height := 20;

    c := g.canvas(width, height, context.temp_allocator);

    expect(t, c.width == width);
    expect(t, c.height == height);

    black := g.color(0, 0, 0);

    for pixel in c.pixels {
        expect(t, pixel == black);
        expect(t, m.eq(pixel, black));
    }
}


@test
Canvas_Write_Pixel :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(10, 20, context.temp_allocator);

    red := g.color(1, 0, 0);

    g.canvas_write_pixel(c, 2, 3, red);

    expect(t, g.canvas_get_pixel(c, 2, 3) == red);
    expect(t, g.eq(g.canvas_get_pixel(c, 2, 3), red));
}

@test
Canvas_PPM_Header :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(5, 3);

    ppm := g.ppm_from_canvas(c, context.temp_allocator);

    ppm_lines := strings.split_lines(ppm, context.temp_allocator);

    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "5 3");
    expect(t, ppm_lines[2] == "255");
}

@test
Canvas_PPM_Pixel_Data_Construction :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(5, 3);
    c1 := g.color(1.5, 0, 0);
    c2 := g.color(0, 0.5, 0);
    c3 := g.color(-0.5, 0, 1);

    g.canvas_write_pixel(c, 0, 0, c1);
    g.canvas_write_pixel(c, 2, 1, c2);
    g.canvas_write_pixel(c, 4, 2, c3);

    ppm := g.ppm_from_canvas(c);

    ppm_lines := strings.split_lines(ppm);

    expect(t, len(ppm_lines) == 7);

    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "5 3");
    expect(t, ppm_lines[2] == "255");
    expect(t, ppm_lines[3] == "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0");
    expect(t, ppm_lines[4] == "0 0 0 0 0 0 0 128 0 0 0 0 0 0 0");
    expect(t, ppm_lines[5] == "0 0 0 0 0 0 0 0 0 0 0 0 0 0 255");
}
@test
Canvas_Clear :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    width := 2;
    height := 2;

    c := g.canvas(width, height);

    clear_color := g.color(1, 2, 3);

    g.canvas_clear(c, clear_color);

    expect(t, g.canvas_get_pixel(c, 0, 0) == clear_color);
    expect(t, g.canvas_get_pixel(c, 1, 0) == clear_color);
    expect(t, g.canvas_get_pixel(c, 0, 1) == clear_color);
    expect(t, g.canvas_get_pixel(c, 1, 1) == clear_color);
}

@test
Canvas_PPM_Line_Splitting :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(10, 2);

    g.canvas_clear(c, g.color(1, 0.8, 0.6));

    ppm := g.ppm_from_canvas(c);

    ppm_lines := strings.split_lines(ppm);

    expect(t, len(ppm_lines) == 8);

    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "10 2");
    expect(t, ppm_lines[2] == "255");
    expect(t, ppm_lines[3] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204");
    expect(t, ppm_lines[4] == "153 255 204 153 255 204 153 255 204 153 255 204 153");
    expect(t, ppm_lines[5] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204");
    expect(t, ppm_lines[6] == "153 255 204 153 255 204 153 255 204 153 255 204 153");
}

@test
Canvas_PPM_Ends_With_Newline :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(5, 3);

    ppm := g.ppm_from_canvas(c);

    expect(t, ppm[len(ppm) - 1] == '\n');
}

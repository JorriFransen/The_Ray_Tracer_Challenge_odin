package tests

import "core:testing"
import "core:strings"

import g "raytracer:graphics"

canvas_suite := Test_Suite {
    name = "Cvs/",
    tests = {
        test("Ca_Constructor", Ca_Constructor),
        test("Ca_Write_Pixel", Ca_Write_Pixel),
        test("Ca_PPM_Header", Ca_PPM_Header),
        test("Ca_PPM_Pixel_Data_Construction", Ca_PPM_Pixel_Data_Construction),
        test("Ca_Clear", Ca_Clear),
        test("Ca_PPM_Line_Splitting", Ca_PPM_Line_Splitting),
        test("Ca_PPM_Ends_With_Newline", Ca_PPM_Ends_With_Newline),
    },
}

@test
Ca_Constructor :: proc(t: ^testing.T) {

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
        expect(t, g.eq(pixel, black));
    }
}


@test
Ca_Write_Pixel :: proc(t: ^testing.T) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(10, 20, context.temp_allocator);

    red := g.color(1, 0, 0);

    g.canvas_write_pixel(c, 2, 3, red);

    expect(t, g.canvas_get_pixel(c, 2, 3) == red);
    expect(t, g.eq(g.canvas_get_pixel(c, 2, 3), red));
}

@test
Ca_PPM_Header :: proc(t: ^testing.T) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(5, 3);

    ppm := g.ppm_from_canvas(c, context.temp_allocator);

    ppm_lines := strings.split_lines(ppm, context.temp_allocator);

    expect(t, len(ppm_lines) >= 3);
    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "5 3");
    expect(t, ppm_lines[2] == "255");
}

@test
Ca_PPM_Pixel_Data_Construction :: proc(t: ^testing.T) {

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
Ca_Clear :: proc(t: ^testing.T) {

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
Ca_PPM_Line_Splitting :: proc(t: ^testing.T) {

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
Ca_PPM_Ends_With_Newline :: proc(t: ^testing.T) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := g.canvas(5, 3);

    ppm := g.ppm_from_canvas(c);

    expect(t, ppm[len(ppm) - 1] == '\n');
}

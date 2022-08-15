package tests_graphics

import "core:strings"

import rt "raytracer:."
import r "raytracer:test_runner"

canvas_suite := r.Test_Suite {
    name = "Cvs/",
    tests = {
        r.test("Ca_Constructor", Ca_Constructor),
        r.test("Ca_Write_Pixel", Ca_Write_Pixel),
        r.test("Ca_PPM_Header", Ca_PPM_Header),
        r.test("Ca_PPM_Pixel_Data_Construction", Ca_PPM_Pixel_Data_Construction),
        r.test("Ca_Clear", Ca_Clear),
        r.test("Ca_PPM_Line_Splitting", Ca_PPM_Line_Splitting),
        r.test("Ca_PPM_Ends_With_Newline", Ca_PPM_Ends_With_Newline),
    },
}

@test
Ca_Constructor :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    width := 10;
    height := 20;

    c := rt.canvas(width, height, context.temp_allocator);

    expect(t, c.width == width);
    expect(t, c.height == height);

    black := rt.color(0, 0, 0);

    for pixel in c.pixels {
        expect(t, pixel == black);
        expect(t, rt.eq(pixel, black));
    }
}


@test
Ca_Write_Pixel :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := rt.canvas(10, 20, context.temp_allocator);

    red := rt.color(1, 0, 0);

    rt.canvas_write_pixel(c, 2, 3, red);

    expect(t, rt.canvas_get_pixel(c, 2, 3) == red);
    expect(t, rt.eq(rt.canvas_get_pixel(c, 2, 3), red));
}

@test
Ca_PPM_Header :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := rt.canvas(5, 3);

    ppm := rt.ppm_from_canvas(c, context.temp_allocator);

    ppm_lines := strings.split_lines(ppm, context.temp_allocator);

    expect(t, len(ppm_lines) >= 3);
    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "5 3");
    expect(t, ppm_lines[2] == "255");
}

@test
Ca_PPM_Pixel_Data_Construction :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := rt.canvas(5, 3);
    c1 := rt.color(1.5, 0, 0);
    c2 := rt.color(0, 0.5, 0);
    c3 := rt.color(-0.5, 0, 1);

    rt.canvas_write_pixel(c, 0, 0, c1);
    rt.canvas_write_pixel(c, 2, 1, c2);
    rt.canvas_write_pixel(c, 4, 2, c3);

    ppm := rt.ppm_from_canvas(c);

    ppm_lines := strings.split_lines(ppm);

    expect(t, len(ppm_lines) == 7);

    for pl in ppm_lines {
        expect(t, len(pl) <= rt.PPM_MAX_LINE_LENGTH);
    }

    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "5 3");
    expect(t, ppm_lines[2] == "255");
    expect(t, ppm_lines[3] == "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0");
    expect(t, ppm_lines[4] == "0 0 0 0 0 0 0 128 0 0 0 0 0 0 0");
    expect(t, ppm_lines[5] == "0 0 0 0 0 0 0 0 0 0 0 0 0 0 255");
}

@test
Ca_Clear :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    width := 2;
    height := 2;

    {
        c := rt.canvas(width, height);

        clear_color := rt.color(1, 2, 3);

        rt.canvas_clear(&c, clear_color);

        expect(t, rt.canvas_get_pixel(c, 0, 0) == clear_color);
        expect(t, rt.canvas_get_pixel(c, 1, 0) == clear_color);
        expect(t, rt.canvas_get_pixel(c, 0, 1) == clear_color);
        expect(t, rt.canvas_get_pixel(c, 1, 1) == clear_color);
    }

    {
        c := rt.canvas(width, height);

        rt.canvas_clear(&c);

        expect(t, rt.canvas_get_pixel(c, 0, 0) == rt.BLACK);
        expect(t, rt.canvas_get_pixel(c, 1, 0) == rt.BLACK);
        expect(t, rt.canvas_get_pixel(c, 0, 1) == rt.BLACK);
        expect(t, rt.canvas_get_pixel(c, 1, 1) == rt.BLACK);
    }
}

@test
Ca_PPM_Line_Splitting :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := rt.canvas(10, 2);

    rt.canvas_clear(&c, rt.color(1, 0.8, 0.6));

    ppm := rt.ppm_from_canvas(c);

    ppm_lines := strings.split_lines(ppm);

    expect(t, len(ppm_lines) == 8);

    for pl in ppm_lines {
        expect(t, len(pl) <= rt.PPM_MAX_LINE_LENGTH);
    }

    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "10 2");
    expect(t, ppm_lines[2] == "255");
    expect(t, ppm_lines[3] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204");
    expect(t, ppm_lines[4] == "153 255 204 153 255 204 153 255 204 153 255 204 153");
    expect(t, ppm_lines[5] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204");
    expect(t, ppm_lines[6] == "153 255 204 153 255 204 153 255 204 153 255 204 153");
}

@test
Ca_PPM_Ends_With_Newline :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    c := rt.canvas(5, 3);

    ppm := rt.ppm_from_canvas(c);

    expect(t, ppm[len(ppm) - 1] == '\n');
}

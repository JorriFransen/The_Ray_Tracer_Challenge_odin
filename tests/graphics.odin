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
}

@test
Color_Constructor :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    c := g.color(-0.5, 0.4, 1.7);

    expected_r := f32(-0.5);
    expected_g := f32(0.4);
    expected_b := f32(1.7);

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

    width : uint = 10;
    height : uint = 20;

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

    c := g.canvas(10, 20, context.temp_allocator);

    red := g.color(1, 0, 0);

    g.write_pixel(c, 2, 3, red);

    expect(t, g.pixel_at(c, 2, 3) == red);
    expect(t, g.eq(g.pixel_at(c, 2, 3), red));
}

@test
Canvas_PPM_Header :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

    free_all(context.temp_allocator);

    c := g.canvas(5, 3);

    ppm := g.canvas_to_ppm(c, context.temp_allocator);

    ppm_lines := strings.split_lines(ppm, context.temp_allocator);

    expect(t, ppm_lines[0] == "P3");
    expect(t, ppm_lines[1] == "5 3");
    expect(t, ppm_lines[2] == "255");
}

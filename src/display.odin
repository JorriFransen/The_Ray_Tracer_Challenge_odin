package raytracer

import "core:math"
import "core:thread"
import rl "vendor:raylib"

Display_Data :: struct {
    title: cstring,
    canvas: ^Canvas,
};

Display :: struct {
    thread: ^thread.Thread,
    data: ^Display_Data,
};

threaded_display_proc :: proc(t: ^thread.Thread) {

    data := transmute(^Display_Data)t.data;

    display_internal(data.canvas, data.title);
}

start_display :: proc(c: ^Canvas, title: cstring) -> Display {

    data := new(Display_Data);
    data.title = title;
    data.canvas = c;

    display_thread := thread.create(threaded_display_proc);
    display_thread.data = data;

    thread.start(display_thread);

    return Display { display_thread, data };
}

end_display :: proc(d: Display) {
    thread.join(d.thread);
    free(d.data);
}

display_internal :: proc(c: ^Canvas, title: cstring) {

    width := i32(c.width);
    height := i32(c.height);

    rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING);

    rl.SetConfigFlags({ .WINDOW_RESIZABLE });

    rl.SetTargetFPS(60);

    rl.InitWindow(width, height, title);
    defer rl.CloseWindow();

    rl.SetWindowMinSize(width, height);

    target := rl.LoadRenderTexture(width, height);
    defer rl.UnloadRenderTexture(target);

    for !rl.WindowShouldClose() {

        rl.BeginDrawing();


        rl.ClearBackground(rl.Color { 100, 100, 120, 0 });

        update_rendertexture(c, target);
        draw_rendertexture(width, height, target);

        rl.EndDrawing();

    }
}

@(private="file")
update_rendertexture :: proc(c: ^Canvas, target: rl.RenderTexture) {

    rl.BeginTextureMode(target);
    rl.ClearBackground(rl.BLACK);

    for y in 0..<c.height {
        for x in 0..<c.width {
            cc := canvas_get_pixel(c^, x, y);
            c := to_raylib_color(cc);
            rl.DrawPixel(i32(x), i32(y), c);
        }
    }

    rl.EndTextureMode();

}

@(private="file")
draw_rendertexture :: proc(width, height: i32, target: rl.RenderTexture) {

    window_width := f32(rl.GetScreenWidth());
    window_height := f32(rl.GetScreenHeight());

    fwidth := f32(width);
    fheight := f32(height);

    image_ratio := fwidth / fheight;
    window_ratio := window_width / window_height;

    dest_x, dest_y, dest_width, dest_height: f32;

    if window_ratio > image_ratio {
        dest_width = fwidth * window_height / fheight;
        dest_height = window_height;
    } else {
        dest_width = window_width;
        dest_height = fheight * window_width / fwidth;
    }

    dest_x = (window_width - dest_width) / 2;
    dest_y = (window_height - dest_height) / 2;

    source_rect := rl.Rectangle { 0, 0, fwidth, -fheight };
    dest_rect := rl.Rectangle { dest_x, dest_y, dest_width, dest_height }; // Relative to top left
    origin := rl.Vector2 { 0, 0 }; // Opengl origin? seems to be relative to bottom left
    rl.DrawTexturePro(target.texture, source_rect, dest_rect, origin, 0, rl.WHITE);
}

@(private="file")
to_raylib_color :: proc(c: Color) -> rl.Color {

    r := clamp(c.r, 0, 1);
    g := clamp(c.g, 0, 1);
    b := clamp(c.b, 0, 1);

    return rl.Color {
        u8(math.ceil(255 * r)),
        u8(math.ceil(255 * g)),
        u8(math.ceil(255 * b)),
        255,
    };
}

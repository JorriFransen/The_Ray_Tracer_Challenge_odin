package graphics

import "core:math"
import rl "vendor:raylib"

display :: proc(c: Canvas, title: cstring) {

    width := i32(c.width);
    height := i32(c.height);

    window_width := f32(c.width);
    window_height := f32(c.height);

    rl.SetConfigFlags({ .WINDOW_RESIZABLE });

    rl.InitWindow(width, height, title);
    defer rl.CloseWindow();

    rl.SetWindowMinSize(width, height);

    target := rl.LoadRenderTexture(width, height);
    defer rl.UnloadRenderTexture(target);

    rl.BeginTextureMode(target);
    rl.ClearBackground(rl.BLACK);

    for y in 0..<c.height {
        for x in 0..<c.width {
            cc := canvas_get_pixel(c, x, y);
            c := to_raylib_color(cc);
            rl.DrawPixel(i32(x), i32(y), c);
        }
    }

    rl.EndTextureMode();

    for !rl.WindowShouldClose() {

        resized := false;
        if rl.IsWindowResized() {
            window_width = f32(rl.GetScreenWidth());
            window_height = f32(rl.GetScreenHeight());
            resized = true;
        }

        rl.BeginDrawing();

        rl.ClearBackground(rl.Color { 100, 100, 120, 0 });

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

        rl.EndDrawing();

    }
}

@(private="file")
to_raylib_color :: proc(c: Color) -> rl.Color {
    return rl.Color {
        u8(math.ceil(255 * c.r)),
        u8(math.ceil(255 * c.g)),
        u8(math.ceil(255 * c.b)),
        255,
    };
}

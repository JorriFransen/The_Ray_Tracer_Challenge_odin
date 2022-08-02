package graphics

import "core:math"
import rl "vendor:raylib"

display :: proc(c: Canvas, title: cstring) {

    width := i32(c.width);
    height := i32(c.height);

    rl.InitWindow(width, height, title);

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

        rl.BeginDrawing();

        rl.ClearBackground(rl.Color { 100, 100, 120, 0 });

        source_rect := rl.Rectangle { 0, 0, f32(target.texture.width), -f32(target.texture.height) };
        rl.DrawTextureRec(target.texture, source_rect, rl.Vector2 { 0, 0 }, rl.WHITE);

        rl.EndDrawing();

    }

    rl.CloseWindow();

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

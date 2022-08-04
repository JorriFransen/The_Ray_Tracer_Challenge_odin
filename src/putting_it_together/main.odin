package putting_it_together

import "core:fmt"
import g "raytracer:graphics"

main :: proc() {

    CH01();
    fmt.println("\n");

    with_canvas(900, 550, CH02, "CH02");
    fmt.println("\n");

    CH03();
    fmt.println("\n");

    with_canvas(500, 500, CH04, "CH04");
    fmt.println("\n");

    with_canvas(500, 500, CH05, "CH05");
    fmt.println("\n");
}

With_Canvas_Proc :: proc(c: g.Canvas);

with_canvas :: proc(width, height: int, p: With_Canvas_Proc, title : cstring = "") {

    assert(width > 0 && height > 0);

    c := g.canvas(width, height);
    defer g.canvas_destroy(&c);

    p(c);

    g.display(c, title);
}



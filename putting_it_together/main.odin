package putting_it_together

import "core:fmt"
import "core:math"

import rt "raytracer:."
import m "raytracer:math"

PI :: m.real(math.PI);

main :: proc() {

    // CH01();
    // fmt.println("\n");

    // with_canvas(900, 550, CH02, "CH02");
    // fmt.println("\n");

    // CH03();
    // fmt.println("\n");

    // with_canvas(500, 500, CH04, "CH04");
    // fmt.println("\n");

    // with_canvas(500, 500, CH05, "CH05");
    // fmt.println("\n");

    // with_canvas(500, 500, CH06, "CH06");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH07, "CH07");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH08, "CH08");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH09, "CH09");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH10_1, "CH10.1");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH10_2, "CH10.2");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH10_3, "CH10.3");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH10_4, "CH10.4");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH10_5, "CH10.5");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH11_1, "CH11.1");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH11_2, "CH11.2");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH12_1, "CH12.1");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH13_1, "CH13.1");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH13_2, "CH13.2");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH13_3, "CH13.3");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH13_4, "CH13.4");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH14_1, "CH14.1");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH14_2, "CH14.2");
    // fmt.println("\n");

    // with_canvas(1920, 1080, CH15_1, "CH15.1");
    // fmt.println("\n");

    with_canvas(1920, 1080, CH15_2, "CH15.2");
    fmt.println("\n");
}

With_Canvas_Proc :: proc(c: rt.Canvas);

with_canvas :: proc(width, height: int, p: With_Canvas_Proc, title : cstring = "") {

    assert(width > 0 && height > 0);

    c := rt.canvas(width, height);
    defer rt.canvas_destroy(&c);

    display := rt.start_display(&c, title);

    p(c);

    rt.end_display(display);
}



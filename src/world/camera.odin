package world

import "core:math"

import m "raytracer:math"
import g "raytracer:graphics"

Camera :: struct {
    size: [2]int,

    fov: m.real,
    pixel_size: m.real,

    half_dim: [2]m.real,

    transform: m.Matrix4,
}

camera :: proc(hsize, vsize: int, fov: m.real) -> Camera {

    half_view := math.tan(fov / 2);
    aspect := m.real(hsize) / m.real(vsize);

    half_width, half_height: m.real;
    if aspect >= 1 {
        half_width = half_view;
        half_height = half_view / aspect;
    } else {
        half_width = half_view * aspect;
        half_height = half_view;
    }

    pixel_size := half_width * 2 / m.real(hsize);

    return Camera {
        { hsize, vsize },
        fov,
        pixel_size,
        { half_width, half_height },
        m.matrix4_identity,
    };
}

camera_ray_for_pixel :: proc(c: ^Camera, x, y: int) -> m.Ray {

    x_offset := (m.real(x) + 0.5) * c.pixel_size;
    y_offset := (m.real(y) + 0.5) * c.pixel_size;

    world_x := c.half_dim.x - x_offset;
    world_y := c.half_dim.y - y_offset;

    inverse_cam_tf := m.matrix_inverse(c.transform);

    pixel := inverse_cam_tf * m.point(world_x, world_y, -1);
    origin := inverse_cam_tf * m.point(0, 0, 0);
    direction := m.normalize(m.sub(pixel, origin));

    return m.ray(origin, direction);
}

render_to_new_canvas :: proc(c: ^Camera, w: ^World, allocator := context.allocator) -> g.Canvas {

    canvas := g.canvas(c.size.x, c.size.y, allocator);
    render_to_canvas(&canvas, c, w);
    return canvas;
}

render_to_canvas :: proc(canvas: ^g.Canvas, c: ^Camera, w: ^World, allocator := context.allocator) {

    assert(canvas.width == c.size.x);
    assert(canvas.height == c.size.y);

    for y in 0..<c.size.y {
        for x in 0..<c.size.x {

            ray := camera_ray_for_pixel(c, x, y);
            color := color_at(w, ray, allocator);
            g.canvas_write_pixel(canvas^, x, y, color);
        }
    }
}

render :: proc {
    render_to_new_canvas,
    render_to_canvas,
}

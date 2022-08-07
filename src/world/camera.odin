package world

import "core:math"

import m "raytracer:math"
import g "raytracer:graphics"

Camera :: struct {
    size: [2]int,

    fov: m.real,
    pixel_size: m.real,

    half_dim: [2]m.real,

    inverse_transform: m.Matrix4,
    ray_origin : m.Point,
}

camera :: proc(hsize, vsize: int, fov: m.real, transform := m.matrix4_identity) -> Camera {

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

    inv_transform := m.matrix_inverse(transform);

    return Camera {
        { hsize, vsize },
        fov,
        pixel_size,
        { half_width, half_height },
        inv_transform,
        inv_transform * m.point(0, 0, 0),
    };
}

camera_ray_for_pixel :: proc(c: ^Camera, x, y: int) -> m.Ray {

    x_offset := (m.real(x) + 0.5) * c.pixel_size;
    y_offset := (m.real(y) + 0.5) * c.pixel_size;

    world_x := c.half_dim.x - x_offset;
    world_y := c.half_dim.y - y_offset;

    pixel := c.inverse_transform * m.point(world_x, world_y, -1);
    direction := m.normalize(m.sub(pixel, c.ray_origin));

    return m.ray(c.ray_origin, direction);
}

render_to_new_canvas :: proc(c: ^Camera, w: ^World, allocator := context.allocator) -> g.Canvas {

    canvas := g.canvas(c.size.x, c.size.y, allocator);
    render_to_canvas(&canvas, c, w);
    return canvas;
}

render_to_canvas :: proc(canvas: ^g.Canvas, c: ^Camera, w: ^World, allocator := context.allocator) {

    assert(canvas.width == c.size.x);
    assert(canvas.height == c.size.y);

    ray_origin := c.inverse_transform * m.point(0, 0, 0);

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

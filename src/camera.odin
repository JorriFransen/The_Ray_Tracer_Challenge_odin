package raytracer

import "core:intrinsics"
import "core:math"
import "core:mem"
import "core:thread"

import m "raytracer:math"

import "tracy:."

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

render_to_new_canvas :: proc(c: ^Camera, w: ^World, allocator := context.allocator) -> Canvas {

    canvas := canvas(c.size.x, c.size.y, allocator);
    render_to_canvas(&canvas, c, w);
    return canvas;
}

render_to_canvas :: proc(canvas: ^Canvas, c: ^Camera, w: ^World, shadows := true, allocator := context.allocator) {

    tracy.Zone();

    assert(canvas.width == c.size.x);
    assert(canvas.height == c.size.y);

    TRACY_MAX_PIXEL_COUNT :: 129600; // (480x270)

    when tracy.ENABLED {
        if canvas.height * canvas.width > TRACY_MAX_PIXEL_COUNT {
            panic("Resolution too high (TRACY is enabled).");
        }
    }

    NUM_THREADS :: 16;

    pool: thread.Pool;
    thread.pool_init(&pool, context.allocator, NUM_THREADS);


    Render_Line_Task_Data :: struct {
        canvas: ^Canvas,
        camera: ^Camera,
        world: ^World,
        shadows: bool,
        allocator: mem.Allocator,
    }

    render_line_task :: proc(t: thread.Task) {

        tracy.Zone();

        data := transmute(^Render_Line_Task_Data)t.data;

        for x in 0..<data.camera.size.x {

            ray := camera_ray_for_pixel(data.camera, x, t.user_index);
            color := color_at(data.world, ray, 5, data.shadows, data.allocator);
            canvas_write_pixel(data.canvas^, x, t.user_index, color);
        }
    }

    data := Render_Line_Task_Data { canvas, c, w, shadows, allocator };

    thread.pool_start(&pool);

    for line in 0..<c.size.y {

        thread.pool_add_task(&pool, context.allocator, render_line_task, &data, line);

        for {
            num_waiting := thread.pool_num_waiting(&pool);
            if num_waiting >= NUM_THREADS * 4 {

                task, got_task := thread.pool_pop_waiting(&pool);
                if got_task {
                    thread.pool_do_work(&pool, task);
                }

            } else {
                break;
            }
        }
    }
    thread.pool_finish(&pool);
}

render :: proc {
    render_to_new_canvas,
    render_to_canvas,
}

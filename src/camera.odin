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
    defer thread.pool_destroy(&pool)

    Render_Line_Task_Data :: struct {
        canvas: ^Canvas,
        camera: ^Camera,
        world: ^World,
        shadows: bool,
        arena: mem.Arena,

        line_start: int,
        line_count: int,
    }
    thread.pool_start(&pool);

    num_tasks := NUM_THREADS * 4;
    lines_per_task := int(math.ceil(f64(c.size.y) / f64(num_tasks)));
    lines_queued := 0;

    task_data := make([]Render_Line_Task_Data, num_tasks);
    defer delete(task_data);

    mem_per_task := mem.Kilobyte * 32;
    task_mem := make([]u8, mem_per_task * num_tasks);
    defer delete(task_mem);

    for _,i in task_data {

        line_count := lines_per_task;
        if lines_queued + line_count > c.size.y {
            line_count = c.size.y - lines_queued;
        }

        task_data[i] = Render_Line_Task_Data { canvas, c, w, shadows, {}, lines_queued, line_count };

        offset := i * mem_per_task;
        mem.init_arena(&task_data[i].arena, task_mem[offset:offset + mem_per_task]);

        allocator := mem.arena_allocator(&task_data[i].arena);

        lines_queued += line_count;

        thread.pool_add_task(&pool, allocator, render_lines_task, &task_data[i], 0);
    }

    render_lines_task :: proc(t: thread.Task) {

        tracy.Zone();

        data := transmute(^Render_Line_Task_Data)t.data;

        for y in data.line_start..<data.line_start + data.line_count {
            for x in 0..<data.camera.size.x {

                tmp := mem.begin_arena_temp_memory(&data.arena);
                allocator := mem.arena_allocator(tmp.arena);
                defer mem.end_arena_temp_memory(tmp);

                ray := camera_ray_for_pixel(data.camera, x, y);
                color := color_at(data.world, ray, 5, data.shadows, allocator);
                canvas_write_pixel(data.canvas^, x, y, color);
            }
        }
    }


    thread.pool_finish(&pool);

}

render :: proc {
    render_to_new_canvas,
    render_to_canvas,
}

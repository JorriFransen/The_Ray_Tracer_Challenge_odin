package world

import "core:slice"

import "raytracer:graphics"
import m "raytracer:math"

World :: struct {
    objects: []Shape,
    light: Maybe(graphics.Point_Light),
}

world_default :: proc() -> World {
    return world(nil, nil);
}

world_ol :: proc(o: []Shape, l: Maybe(graphics.Point_Light)) -> World {
    return World { o, l };
}

world :: proc {
    world_default,
    world_ol,
}

intersect_world :: proc(w: ^World, r: m.Ray, allocator := context.allocator) -> [dynamic]Intersection {

    result := make([dynamic]Intersection, allocator);

    for obj in w.objects {
        if xs, ok := intersects(obj, r).?; ok {
            append(&result, .. xs[:]);
        }
    }

    slice.sort_by(result[:], intersection_less);

    return result;
}

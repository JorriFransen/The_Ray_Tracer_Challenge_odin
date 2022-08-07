package world

import "core:slice"

import "raytracer:graphics"
import m "raytracer:math"

World :: struct {
    objects: []Shape,
    lights: []graphics.Point_Light,
}

world_default :: proc() -> World {
    return world(nil, nil);
}

world_ol :: proc(o: []Shape, l: []graphics.Point_Light) -> World {
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

shade_hit :: proc(w: ^World, hi: Hit_Info, shadows := true) -> (result: graphics.Color) {
    assert(len(w.lights) > 0);


    for l in &w.lights {
        is_shadowed :=  shadows && is_shadowed(w, hi.over_point, &l);
        result += graphics.lighting(hi.object.?.material, l, hi.point, hi.eye_v, hi.normal_v, is_shadowed)
    }

    return;
}

color_at :: proc(w: ^World, r: m.Ray, shadows := true, allocator := context.allocator) -> graphics.Color {

    xs := intersect_world(w, r, allocator);
    defer delete(xs);

    if hit, ok := hit(xs[:]).?; ok {

        hi := hit_info(hit, r);

        return shade_hit(w, hi, shadows);

    } else {
        return graphics.BLACK;
    }
}

is_shadowed :: proc(w: ^World, p: m.Point, l: ^graphics.Point_Light, allocator := context.allocator) -> bool {

    point_to_light := m.sub(l.position, p);
    distance := m.magnitude(point_to_light);

    ray := m.ray(p, m.normalize(point_to_light));

    intersections := intersect_world(w, ray, allocator);
    defer delete(intersections);

    if hit, ok := hit(intersections[:]).?; ok {
        return hit.t < distance;
    }

    return false;
}

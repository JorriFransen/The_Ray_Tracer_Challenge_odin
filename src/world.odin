package raytracer

import "core:slice"

import rt "raytracer:."
import m "raytracer:math"

import "tracy:."

World :: struct {
    objects: []^rt.Shape,
    lights: []Point_Light,
}

world_default :: proc() -> World {
    return world(nil, nil);
}

world_ol :: proc(o: []^rt.Shape, l: []Point_Light) -> World {
    return World { o, l };
}

world :: proc {
    world_default,
    world_ol,
}

intersect_world :: proc(w: ^World, r: m.Ray, allocator := context.allocator) -> [dynamic]Intersection {

    tracy.Zone();

    result, err := make([dynamic]Intersection, allocator);
    if err != nil do panic("Allocation failed!");

    for obj in w.objects {
        if xs, ok := intersects(obj, r).?; ok {
            append(&result, .. xs[:]);
        }
    }

    {
        tracy.Zone("intersect_world -- sort");
        slice.sort_by(result[:], intersection_less);
    }

    return result;
}

shade_hit :: proc(w: ^World, hi: ^Hit_Info, shadows := true, remaining := 5) -> (result: Color) {

    tracy.Zone();

    assert(len(w.lights) > 0);

    surface := rt.BLACK;

    for l in &w.lights {
        is_shadowed :=  shadows && is_shadowed(w, hi.over_point, &l);
        surface += lighting(hi.object, l, hi.over_point, hi.eye_v, hi.normal_v, is_shadowed)
    }

    reflected := reflected_color(w, hi, remaining);
    refracted := refracted_color(w, hi, remaining);

    material := hi.object.material;
    if material.reflective > 0 && material.transparency > 0 {
        reflectance := schlick(hi);

        result = surface +
                 reflected * reflectance +
                 refracted * (1 - reflectance);
    } else {
        result = surface + reflected + refracted;
    }


    return;
}

color_at :: proc(w: ^World, r: m.Ray, remaining := 0, shadows := true, allocator := context.allocator) -> Color {

    tracy.Zone();

    xs := intersect_world(w, r, allocator);
    defer delete(xs);

    if hit, ok := hit(xs[:]).?; ok {

        hi := hit_info(hit, r, xs[:]);

        return shade_hit(w, &hi, shadows, remaining);

    } else {
        return BLACK;
    }
}

is_shadowed :: proc(w: ^World, p: m.Point, l: ^Point_Light, allocator := context.allocator) -> bool {

    tracy.Zone();

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

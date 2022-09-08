package raytracer

import "core:slice"
import "core:mem"

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

intersect_world :: proc(w: ^World, r: m.Ray, result: []Intersection) -> []Intersection {

    tracy.Zone();

    assert(len(result) >= len(w.objects) * 2);
    slice.fill(result, Intersection {});

    total_count := 0;

    for obj in w.objects {

        if xs, count := intersects(obj, r); count > 0 {

            assert(count >= 0 && count <= 4);
            for i in 0..<count {
                result[total_count] = xs[i];
                total_count += 1;
            }
        }
    }

    {
        tracy.Zone("intersect_world -- sort");
        slice.sort_by(result[:total_count], intersection_less);
    }

    return result[:total_count];
}

shade_hit :: proc(w: ^World, hi: ^Hit_Info, xs_mem: []Intersection, hi_mem: []^Shape, shadows := true, remaining := 5) -> (result: Color) {

    tracy.Zone();

    assert(len(w.lights) > 0);

    surface := rt.BLACK;

    for l in &w.lights {
        is_shadowed :=  shadows && is_shadowed(w, hi.over_point, &l, xs_mem);
        surface += lighting(hi.object, l, hi.over_point, hi.eye_v, hi.normal_v, is_shadowed)
    }

    reflected := reflected_color(w, hi, xs_mem, hi_mem,  remaining);
    refracted := refracted_color(w, hi, xs_mem, hi_mem, remaining);

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

color_at :: proc(w: ^World, r: m.Ray, xs_mem: []Intersection, hi_mem: []^Shape, remaining := 0, shadows := true) -> Color {

    tracy.Zone();

    xs := intersect_world(w, r, xs_mem);

    if hit, ok := hit(xs[:]).?; ok {

        hi := hit_info(hit, r, xs[:], hi_mem);

        return shade_hit(w, &hi, xs_mem, hi_mem, shadows, remaining);

    } else {
        return BLACK;
    }
}

is_shadowed :: proc(w: ^World, p: m.Point, l: ^Point_Light, xs_mem: []Intersection) -> bool {

    tracy.Zone();

    point_to_light := m.sub(l.position, p);
    distance := m.magnitude(point_to_light);

    ray := m.ray(p, m.normalize(point_to_light));

    xs := intersect_world(w, ray, xs_mem);

    if hit, ok := hit(xs[:]).?; ok {
        return hit.t < distance;
    }

    return false;
}

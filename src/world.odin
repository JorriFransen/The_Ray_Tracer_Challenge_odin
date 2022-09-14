package raytracer

import "core:mem"
import "core:slice"
import "core:sync"

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

total_xs_test_mutex : sync.Mutex;
total_xs_test := 0;
total_hit := 0;

intersect_world :: proc(w: ^World, r: m.Ray, xs_buf: ^Intersection_Buffer) -> []Intersection {

    tracy.Zone();

    xs_buf.count = 0;

    for obj in w.objects {
        intersects(obj, r, xs_buf);
    }

    {
        tracy.Zone("intersect_world -- sort");
        slice.sort_by(xs_buf.intersections[:xs_buf.count], intersection_less);
    }

    sync.mutex_lock(&total_xs_test_mutex);
    total_xs_test += len(w.objects);
    total_hit += xs_buf.count;
    sync.mutex_unlock(&total_xs_test_mutex);


    return xs_buf.intersections[:xs_buf.count];
}

shade_hit :: proc(w: ^World, hi: ^Hit_Info, intersections: ^Intersection_Buffer, hi_mem: []^Shape, shadows := true, remaining := 5) -> (result: Color) {

    tracy.Zone();

    assert(len(w.lights) > 0);

    surface := rt.BLACK;

    for l in &w.lights {
        is_shadowed :=  shadows && is_shadowed(w, hi.over_point, &l, intersections);
        surface += lighting(hi.object, l, hi.over_point, hi.eye_v, hi.normal_v, is_shadowed)
    }

    reflected := reflected_color(w, hi, intersections, hi_mem,  remaining);
    refracted := refracted_color(w, hi, intersections, hi_mem, remaining);

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

color_at :: proc(w: ^World, r: m.Ray, intersections: ^Intersection_Buffer, hi_mem: []^Shape, remaining := 0, shadows := true) -> Color {

    tracy.Zone();

    xs := intersect_world(w, r, intersections);

    if hit, ok := hit(xs[:]).?; ok {

        hi := hit_info(hit, r, xs[:], hi_mem);

        return shade_hit(w, &hi, intersections, hi_mem, shadows, remaining);

    } else {
        return BLACK;
    }
}

is_shadowed :: proc(w: ^World, p: m.Point, l: ^Point_Light, intersections: ^Intersection_Buffer) -> bool {

    tracy.Zone();

    point_to_light := m.sub(l.position, p);
    distance := m.magnitude(point_to_light);

    ray := m.ray(p, m.normalize(point_to_light));

    xs := intersect_world(w, ray, intersections);

    if hit, ok := hit(xs[:]).?; ok {
        return hit.t < distance;
    }

    return false;
}

world_to_object :: proc(s: ^Shape, p: m.Point) -> m.Point {

    point := p;

    if s.parent != nil {
        point = world_to_object(s.parent, point);
    }

    return s.inverse_transform * point;
}

normal_to_world :: proc(s: ^Shape, normal: m.Vector) -> m.Vector {

    normal := m.matrix4_transpose(s.inverse_transform) * normal;
    normal.w = 0;
    normal = m.normalize(normal);

    if s.parent != nil {
        normal = normal_to_world(s.parent, normal);
    }

    return normal;
}

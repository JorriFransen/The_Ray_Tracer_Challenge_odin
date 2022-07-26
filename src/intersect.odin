package raytracer

import "core:math"
import "core:slice"

import m "raytracer:math"
import rt "raytracer:."

import "tracy:."

Intersection :: struct {
    t: m.real,
    object: ^Shape,
    u, v: m.real,
}

Intersection_Buffer :: struct {
    intersections: []Intersection,
    count: int,
}

Hit_Info :: struct {
    t: m.real,
    object: ^Shape,
    point: m.Point,
    over_point: m.Point,
    under_point: m.Point,
    eye_v: m.Vector,
    normal_v: m.Vector,
    reflect_v: m.Vector,

    n1, n2: m.real `Refractive indices`,

    inside: bool,
}

intersection_ :: proc(t: m.real, s: ^Shape) -> Intersection {
    assert(s != nil);
    return Intersection { t, s, 0, 0 };
}

intersection_uv :: proc(t: m.real, s: ^Shape, u, v: m.real) -> Intersection {
    assert(s != nil);
    return Intersection { t, s, u, v };
}

intersection :: proc {
    intersection_,
    intersection_uv,
}

intersection_buffer_s :: proc(objects: []^Shape, allocator := context.allocator) -> Intersection_Buffer {

    xs_mem := make([]Intersection, len(objects) * 4, allocator);
    return Intersection_Buffer { xs_mem, 0 };
}

intersection_buffer_i :: proc(cap: int, allocator := context.allocator) -> Intersection_Buffer {

    return Intersection_Buffer { make([]Intersection, cap, allocator), 0 };
}

intersection_buffer :: proc {
    intersection_buffer_s,
    intersection_buffer_i,
}

append_xs :: proc(buf: ^Intersection_Buffer, i: Intersection) {
    assert(buf.count < len(buf.intersections))

    buf.intersections[buf.count] = i;
    buf.count += 1;
}

intersections_from_slice :: proc(intersections: .. Intersection, allocator := context.allocator) -> [dynamic]Intersection {
    result := slice.clone_to_dynamic(intersections, allocator);
    slice.sort_by(result[:], intersection_less);
    return result;
}

intersections_from_dyn_arr_and_slice :: proc(dxs: ^[dynamic]Intersection, ixs: .. Intersection) {
    append(dxs, .. ixs);
    slice.sort_by(dxs[:], intersection_less);
}

intersections :: proc {
    intersections_from_slice,
    intersections_from_dyn_arr_and_slice,
}

hit_info :: proc(hit: Intersection, r: m.Ray, xs: []Intersection, hi_mem: []^Shape) -> Hit_Info {

    tracy.Zone();

    obj := hit.object;
    point := m.ray_position(r, hit.t);


    eye_v := m.negate(r.direction);
    normal_v := shape_normal_at(obj, point, hit.u, hit.v);

    reflect_v := m.reflect(r.direction, normal_v);

    inside := false;
    if m.dot(normal_v, eye_v) < 0 {
        inside = true;
        normal_v = m.negate(normal_v);
    }

    offset := mul(normal_v, m.FLOAT_EPSILON);

    over_point := rt.add(point, offset);
    over_point.w = 1.0;
    assert(m.is_point(over_point));

    under_point := m.sub(point, offset);
    under_point.w = 1.0;
    assert(m.is_point(under_point));

    n1, n2: m.real;

    if len(xs) > 0 {

        assert(len(hi_mem) >= len(xs) / 2);
        slice.fill(hi_mem, nil);
        container_count := 0;

        for i in xs {
            if i == hit {
                if container_count < 1 {
                    n1 = 1.0;
                } else {
                    n1 = hi_mem[container_count - 1].material.refractive_index;
                }
            }

            if idx, found := slice.linear_search(hi_mem[:container_count], i.object); found {
                slice.swap(hi_mem, idx, container_count - 1);
                container_count -= 1;
            } else {
                hi_mem[container_count] = i.object;
                container_count += 1;
            }

            if i == hit {
                if container_count < 1 {
                    n2 = 1.0;
                } else {
                    n2 = hi_mem[container_count - 1].material.refractive_index;
                }
            }

        }
    }

    return Hit_Info {
        t = hit.t,
        object = hit.object,
        point = point,
        over_point = over_point,
        under_point = under_point,
        eye_v = eye_v,
        normal_v = normal_v,
        reflect_v = reflect_v,
        inside = inside,
        n1 = n1,
        n2 = n2,
    };
}
@private
intersection_less :: proc(a, b: Intersection) -> bool {
    return a.t < b.t;
}

hit :: proc(xs: []Intersection) -> Maybe(Intersection) {

    for i in xs {
        assert(i.object != nil);
        if i.t >= 0 do return i;
    }

    return nil;
}

intersects :: proc(shape: ^Shape, r: m.Ray, xs_buf: ^Intersection_Buffer) -> []Intersection {

    assert(shape.vtable.intersects != nil);

    r := m.ray_transform(r, shape.inverse_transform);

    return shape->intersects(r, xs_buf);
}

schlick :: proc(hit: ^Hit_Info) -> m.real {

    // find the cosine of the angle between the eye and normal vectors
    cos := m.dot(hit.eye_v, hit.normal_v);

    // total internal reflection can only occur if n1 > n2
    if hit.n1 > hit.n2 {
        n := hit.n1 / hit.n2;
        sin2_t := math.pow(n, 2) * (1 - math.pow(cos, 2));

        if sin2_t > 1 do return 1;

        // Compute cosine of theta_t using trig identity
        cos_t := math.sqrt(1 - sin2_t);

        // when n1 > n2, use cos(theta_t) instead
        cos = cos_t;
    }

    r0 := math.pow((hit.n1 - hit.n2) / (hit.n1 + hit.n2), 2);
    return r0 + (1 - r0) * math.pow(1 - cos, 5);
}

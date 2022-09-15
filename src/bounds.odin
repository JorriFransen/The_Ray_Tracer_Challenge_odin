package raytracer

import m "raytracer:math"

import "tracy:."

Bounds :: struct
{
    min, max: m.Point,
}

bounds_default :: proc() -> Bounds {
    return Bounds { m.point(m.INFINITY, m.INFINITY, m.INFINITY),
                    m.point(-m.INFINITY, -m.INFINITY, -m.INFINITY) };
}

bounds_minp_maxp :: proc(min: m.Point, max: m.Point) -> Bounds {
    return Bounds { min, max };
}

bounds_minxyz_maxxyz :: proc(minx, miny, minz, maxx, maxy, maxz: m.real) -> Bounds {
    return Bounds { m.point(minx, miny, minz), m.point(maxx, maxy, maxz) };
}

bounds_add_p :: proc(b: Bounds, p: m.Point) -> (result: Bounds) {

    minx := min(b.min.x, p.x);
    miny := min(b.min.y, p.y);
    minz := min(b.min.z, p.z);

    maxx := max(b.max.x, p.x);
    maxy := max(b.max.y, p.y);
    maxz := max(b.max.z, p.z);

    result.min = m.point(minx, miny, minz);
    result.max = m.point(maxx, maxy, maxz);
    return;
}

bounds_add_b :: proc(a, b: Bounds) -> Bounds {

    result := a;
    result = bounds(result, b.min);
    result = bounds(result, b.max);
    return result;
}

bounds :: proc {
    bounds_default,
    bounds_minp_maxp,
    bounds_minxyz_maxxyz,
    bounds_add_p,
    bounds_add_b,
}

bounds_transform :: proc(b: Bounds, tf: m.Matrix4) -> Bounds {

    p1 := tf * b.min;
    p2 := tf * m.point(b.min.x, b.min.y, b.max.z);
    p3 := tf * m.point(b.min.x, b.max.y, b.min.z);
    p4 := tf * m.point(b.min.x, b.max.y, b.max.z);
    p5 := tf * m.point(b.max.x, b.min.y, b.min.z);
    p6 := tf * m.point(b.max.x, b.min.y, b.max.z);
    p7 := tf * m.point(b.max.x, b.max.y, b.min.z);
    p8 := tf * b.max;

    minx := min(p1.x, p2.x, p3.x, p4.x, p5.x, p6.x, p7.x, p8.x);
    miny := min(p1.y, p2.y, p3.y, p4.y, p5.y, p6.y, p7.y, p8.y);
    minz := min(p1.z, p2.z, p3.z, p4.z, p5.z, p6.z, p7.z, p8.z);

    maxx := max(p1.x, p2.x, p3.x, p4.x, p5.x, p6.x, p7.x, p8.x);
    maxy := max(p1.y, p2.y, p3.y, p4.y, p5.y, p6.y, p7.y, p8.y);
    maxz := max(p1.z, p2.z, p3.z, p4.z, p5.z, p6.z, p7.z, p8.z);

    return bounds(minx, miny, minz, maxx, maxy, maxz);
}

parent_space_bounds :: proc(s: ^Shape) -> Bounds {
    return bounds_transform(s->get_bounds(), m.matrix_inverse(s.inverse_transform));
}

bounds_intersect :: proc(b: Bounds, r: m.Ray) ->  bool {

    tracy.Zone();

    inv_dir := r.inverse_direction;

    tmin, tmax : m.real;

    if inv_dir.x >= 0 {
        tmin = (b.min.x - r.origin.x) * inv_dir.x;
        tmax = (b.max.x - r.origin.x) * inv_dir.x;
    } else {
        tmin = (b.max.x - r.origin.x) * inv_dir.x;
        tmax = (b.min.x - r.origin.x) * inv_dir.x;
    }

    tymin, tymax : m.real;

    if inv_dir.y >= 0 {
        tymin = (b.min.y - r.origin.y) * inv_dir.y;
        tymax = (b.max.y - r.origin.y) * inv_dir.y;
    } else {
        tymin = (b.max.y - r.origin.y) * inv_dir.y;
        tymax = (b.min.y - r.origin.y) * inv_dir.y;
    }

    if tmin > tymax || tymin > tmax do return false;

    if tymin > tmin do tmin = tymin;
    if tymax < tmax do tmax = tymax;

    tzmin, tzmax : m.real;

    if inv_dir.z >= 0 {
        tzmin = (b.min.z - r.origin.z) * inv_dir.z;
        tzmax = (b.max.z - r.origin.z) * inv_dir.z;
    } else {
        tzmin = (b.max.z - r.origin.z) * inv_dir.z;
        tzmax = (b.min.z - r.origin.z) * inv_dir.z;
    }

    if tmin > tzmax || tzmin > tmax do return false;

    return true;
}

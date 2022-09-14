package raytracer

import m "raytracer:math"

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

bounds_add :: proc(b: Bounds, p: m.Point) -> (result: Bounds) {

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

bounds :: proc {
    bounds_default,
    bounds_minp_maxp,
    bounds_minxyz_maxxyz,
    bounds_add,
}


package raytracer

import m "raytracer:math"

Test_Shape :: struct {
    using shape: Shape,

    saved_ray: m.Ray,
}

test_shape :: proc() -> Test_Shape {

    return Test_Shape { shape(_test_shape_vtable, m.matrix4_identity, material()), {} };

}

_test_shape_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {
        return m.vector(p.x, p.y, p.z);
    },

    intersects = proc(s: ^Shape, r: m.Ray, xs_buf: ^Intersection_Buffer) -> []Intersection {
        ts := transmute(^Test_Shape)s;
        ts.saved_ray = r;
        return {};
    },

    get_bounds = proc(shape: ^Shape) -> Bounds { return Bounds { m.point(-1, -1, -1), m.point(1, 1, 1) }; },

    eq = proc(a, b: ^Shape) -> bool { assert(false); return true },

};

test_shape_normal_at :: proc(ts: ^Test_Shape, p: m.Point) -> m.Vector {
    return m.vector(p.x, p.y, p.z)
}

test_shape_intersects :: proc(ts: ^Test_Shape, r: m.Ray) -> Maybe([2]Intersection) {
    ts.saved_ray = r;
    return nil;
}

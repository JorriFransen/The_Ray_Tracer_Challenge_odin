package tests_world

import "core:slice"

import r "../runner"

import g "raytracer:graphics"
import m "raytracer:math"
import world "raytracer:world"

world_suite := r.Test_Suite {
    name = "World/",
    tests = {
        r.test("World_Default", World_Default),
        r.test("World_Test_Default", World_Test_Default),
        r.test("World_Intersect_Ray", World_Intersect_Ray),
    },

    child_suites = {
        &shape_suite,
        &intersect_suite,
    },
}

@(private="file")
default_test_world_shapes : [2]world.Shape = {
    world.sphere(g.material(color=g.color(0.8, 1.0, 0.6), diffuse=0.7, specular=0.2)),
    world.sphere(m.scaling(0.5, 0.5, 0.5)),
};

@(private="file")
default_world :: proc() -> world.World {
    light := g.point_light(m.point(-10, 10, -10), g.color(1, 1, 1));

    return world.world(default_test_world_shapes[:], light);
}

@test
World_Default :: proc(t: ^r.T) {

    w := world.world();

    r.expect(t, len(w.objects) == 0);
    r.expect(t, w.light == nil);

    _,l_ok := w.light.?;
    r.expect(t, !l_ok);
}

@test
World_Test_Default :: proc(t: ^r.T) {

    light := g.point_light(m.point(-10, 10, -10), g.color(1, 1, 1));
    mat := g.material(color=g.color(0.8, 1.0, 0.6), diffuse=0.7, specular=0.2);
    s1 := world.sphere(mat);
    tf := m.scaling(0.5, 0.5, 0.5);
    s2 := world.sphere(tf);

    w := default_world();

    r.expect(t, w.light == light);
    r.expect(t, slice.contains(w.objects, s1));
}

@test
World_Intersect_Ray :: proc(t: ^r.T) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    w := default_world();
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs := world.intersect_world(&w, ray);

    r.expect(t, len(xs) == 4);
    r.expect(t, xs[0].t == 4);
    r.expect(t, xs[1].t == 4.5);
    r.expect(t, xs[2].t == 5.5);
    r.expect(t, xs[3].t == 6);
}

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
        r.test("Shade_Intersection", Shade_Intersection),
        r.test("Shade_Intersection_Inside", Shade_Intersection_Inside),
        r.test("Color_At_Miss", Color_At_Miss),
        r.test("Color_At_Hit", Color_At_Hit),
        r.test("Color_At_Hit_Behind", Color_At_Hit_Behind),
    },

    child_suites = {
        &shape_suite,
        &intersect_suite,
    },
}


@(private="file") @(deferred_out=destroy_default_world)
default_world :: proc() -> ^world.World {

    shapes : [dynamic]world.Shape = {
        world.sphere(g.material(color = g.color(0.8, 1, 0.6), diffuse = 0.7, specular = 0.2)),
        world.sphere(m.scaling(0.5, 0.5, 0.5)),
    };

    lights: [dynamic]g.Point_Light = {
        g.point_light(m.point(-10, 10, -10), g.color(1, 1, 1)),
    };

    result := new(world.World);
    result.lights = lights[:];
    result.objects = shapes[:];
    return result;
}

@(private="file")
destroy_default_world :: proc(w: ^world.World) {
    delete(w.objects);
    delete(w.lights);
    free(w);
    w^ = ---;
}

@test
World_Default :: proc(t: ^r.T) {

    w := world.world();

    r.expect(t, len(w.objects) == 0);
    r.expect(t, len(w.lights) == 0);
}

@test
World_Test_Default :: proc(t: ^r.T) {

    light := g.point_light(m.point(-10, 10, -10), g.color(1, 1, 1));
    mat := g.material(color=g.color(0.8, 1.0, 0.6), diffuse=0.7, specular=0.2);
    s1 := world.sphere(mat);
    tf := m.scaling(0.5, 0.5, 0.5);
    s2 := world.sphere(tf);

    w := default_world();

    r.expect(t, len(w.lights) == 1);
    r.expect(t, w.lights[0] == light);

    r.expect(t, len(w.objects) == 2);
    r.expect(t, slice.contains(w.objects, s1));
    r.expect(t, slice.contains(w.objects, s2));
}

@test
World_Intersect_Ray :: proc(t: ^r.T) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    w := default_world();
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs := world.intersect_world(w, ray);

    r.expect(t, len(xs) == 4);
    r.expect(t, xs[0].t == 4);
    r.expect(t, xs[1].t == 4.5);
    r.expect(t, xs[2].t == 5.5);
    r.expect(t, xs[3].t == 6);
}

@test
Shade_Intersection :: proc(t: ^r.T) {

    w := default_world();
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    shape := w.objects[0];
    i := world.intersection(4, shape);

    comps := world.hit_info(i, ray);
    c := world.shade_hit(w, comps);

    r.expect(t, m.eq(c, g.color(0.38066, 0.47583, 0.2855)));
}

@test
Shade_Intersection_Inside :: proc(t: ^r.T) {
    w := default_world();
    w.lights[0] = g.point_light(m.point(0, 0.25, 0), g.color(1, 1, 1));
    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    shape := w.objects[1];
    i := world.intersection(0.5, shape);

    comps := world.hit_info(i, ray);
    c := world.shade_hit(w, comps);

    r.expect(t, m.eq(c, g.color(0.90498, 0.90498, 0.90498)));
}

@test
Color_At_Miss :: proc(t: ^r.T) {

    w := default_world();
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 1, 0));

    c := world.color_at(w, ray);

    r.expect(t, m.eq(c, g.color(0, 0, 0)));
}

@test
Color_At_Hit :: proc(t: ^r.T) {

    w := default_world();
    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    c := world.color_at(w, ray);

    r.expect(t, m.eq(c, g.color(0.38066, 0.47583, 0.2855)));
}

@test
Color_At_Hit_Behind :: proc(t: ^r.T) {

    w := default_world();
    outer := &w.objects[0].?;
    outer.material.ambient = 1;
    inner := &w.objects[1].?;
    inner.material.ambient = 1;
    ray := m.ray(m.point(0, 0, 0.75), m.vector(0, 0, -1));

    c := world.color_at(w, ray);

    r.expect(t, m.eq(c, inner.material.color));
}

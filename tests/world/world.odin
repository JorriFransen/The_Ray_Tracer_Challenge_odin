package tests_world

import "core:slice"
import "core:math"

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

eq :: rt.eq;
expect :: r.expect;

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
        r.test("No_Shadow_Complete_Miss", No_Shadow_Complete_Miss),
        r.test("Shadow_Point_Object_Light", Shadow_Point_Object_Light),
        r.test("Shadow_Point_Light_Object", Shadow_Point_Light_Object),
        r.test("Shadow_Light_Point_Object", Shadow_Light_Point_Object),
        r.test("Shade_Shadowed_Intersection", Shade_Shadowed_Intersection),
        r.test("Reflected_Color_Non_Reflective_Material", Reflected_Color_Non_Reflective_Material),
        r.test("Reflected_Color_Reflective_Material", Reflected_Color_Reflective_Material),
        r.test("Shade_Hit_Reflective_Material", Shade_Hit_Reflective_Material),
        r.test("Limit_Reflection_Recursion", Limit_Reflection_Recursion),
        r.test("Avoid_Infinite_Reflection_Recursion", Avoid_Infinite_Reflection_Recursion),
        r.test("Refract_Opaque_Surface", Refract_Opaque_Surface),
        r.test("Refract_Max_Recursion", Refract_Max_Recursion),
        r.test("Refract_Total_Internal", Refract_Total_Internal),
        r.test("Refracted_Color", Refracted_Color),
        r.test("Shade_Hit_Transparent_Material", Shade_Hit_Transparent_Material),
    },

    child_suites = {
        &shape_suite,
        &intersect_suite,
        &camera_suite,
    },
}


_default_sphere_1 : rt.Sphere;
_default_sphere_2 : rt.Sphere;

default_world :: proc() -> ^rt.World {

    _default_sphere_1 = rt.sphere(rt.material(color = rt.color(0.8, 1, 0.6), diffuse = 0.7, specular = 0.2));
    _default_sphere_2 = rt.sphere(m.scaling(0.5, 0.5, 0.5));

    shapes : [dynamic]^rt.Shape = {
        &_default_sphere_1,
        &_default_sphere_2,
    };

    lights: [dynamic]rt.Point_Light = {
        rt.point_light(m.point(-10, 10, -10), rt.color(1, 1, 1)),
    };

    result := new(rt.World);
    result.lights = lights[:];
    result.objects = shapes[:];
    return result;
}

@(private)
destroy_default_world :: proc(w: ^rt.World) {
    delete(w.objects);
    delete(w.lights);
    free(w);
    w^ = ---;
}

@test
World_Default :: proc(t: ^r.Test_Context) {

    w := rt.world();

    expect(t, len(w.objects) == 0);
    expect(t, len(w.lights) == 0);
}

@test
World_Test_Default :: proc(t: ^r.Test_Context) {

    light := rt.point_light(m.point(-10, 10, -10), rt.color(1, 1, 1));
    mat := rt.material(color=rt.color(0.8, 1.0, 0.6), diffuse=0.7, specular=0.2);
    s1 := rt.sphere(mat);
    tf := m.scaling(0.5, 0.5, 0.5);
    s2 := rt.sphere(tf);

    w := default_world();
    defer destroy_default_world(w);

    expect(t, len(w.lights) == 1);
    expect(t, w.lights[0] == light);

    expect(t, len(w.objects) == 2);
    expect(t, eq(w.objects[0]^, s1));
    expect(t, eq(w.objects[1]^, s2));
}

@test
World_Intersect_Ray :: proc(t: ^r.Test_Context) {

    free_all(context.temp_allocator);
    context.allocator = context.temp_allocator;

    w := default_world();
    defer destroy_default_world(w);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs := rt.intersect_world(w, ray);

    expect(t, len(xs) == 4);
    expect(t, xs[0].t == 4);
    expect(t, xs[1].t == 4.5);
    expect(t, xs[2].t == 5.5);
    expect(t, xs[3].t == 6);
}

@test
Shade_Intersection :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    shape := w.objects[0];
    i := rt.intersection(4, shape);

    comps := rt.hit_info(i, ray, nil);
    c := rt.shade_hit(w, &comps);

    expect(t, eq(c, rt.color(0.38066, 0.47583, 0.2855)));
}

@test
Shade_Intersection_Inside :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    w.lights[0] = rt.point_light(m.point(0, 0.25, 0), rt.color(1, 1, 1));
    ray := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    shape := w.objects[1];
    i := rt.intersection(0.5, shape);

    comps := rt.hit_info(i, ray, nil);
    c := rt.shade_hit(w, &comps);

    expect(t, eq(c, rt.color(0.90498, 0.90498, 0.90498)));
}

@test
Color_At_Miss :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 1, 0));

    c := rt.color_at(w, ray, 1);

    expect(t, eq(c, rt.color(0, 0, 0)));
}

@test
Color_At_Hit :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    c := rt.color_at(w, ray);

    expect(t, eq(c, rt.color(0.38066, 0.47583, 0.2855)));
}

@test
Color_At_Hit_Behind :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    outer := w.objects[0];
    outer.material.ambient = 1;
    inner := w.objects[1];
    inner.material.ambient = 1;
    ray := m.ray(m.point(0, 0, 0.75), m.vector(0, 0, -1));

    c := rt.color_at(w, ray);

    expect(t, eq(c, inner.material.color));
}

@test
No_Shadow_Complete_Miss :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    p := m.point(0, 10, 0);

    expect(t, rt.is_shadowed(w, p, &w.lights[0]) == false);
}

@test
Shadow_Point_Object_Light :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    p := m.point(10, -10, 10);

    expect(t, rt.is_shadowed(w, p, &w.lights[0]));
}

@test
Shadow_Point_Light_Object :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    p := m.point(-20, 20, -20);

    expect(t, rt.is_shadowed(w, p, &w.lights[0]) == false);
}

@test
Shadow_Light_Point_Object :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    p := m.point(-2, 2, -2);

    expect(t, rt.is_shadowed(w, p, &w.lights[0]) == false);
}

@test
Shade_Shadowed_Intersection :: proc(t: ^r.Test_Context) {

    s1 := rt.sphere();
    s2 := rt.sphere(m.translation(0, 0, 10));
    shapes : []^rt.Shape = { &s1, &s2 };

    lights : []rt.Point_Light = { rt.point_light(m.point(0, 0, -10), rt.color(1, 1, 1)) };

    w := rt.world(shapes, lights);

    ray := m.ray(m.point(0, 0, 5), m.vector(0, 0, 1));
    i := rt.intersection(4, &s2);

    hit_info := rt.hit_info(i, ray, nil);

    c := rt.shade_hit(&w, &hit_info);

    expect(t, eq(c, rt.color(0.1, 0.1, 0.1)));
}

@test
Reflected_Color_Non_Reflective_Material :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    r := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));
    shape := w.objects[1];
    shape.material.ambient = 1;
    i := rt.intersection(1, shape);

    comps := rt.hit_info(i, r, nil);
    color := rt.reflected_color(w, &comps);

    expect(t, eq(color, rt.BLACK));
}

@test
Reflected_Color_Reflective_Material :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    shape := rt.plane(m.translation(0, -1, 0), rt.material(reflective=0.5));

    new_objects := []^rt.Shape { w.objects[0], w.objects[1], &shape };
    old_objects := w.objects;
    w.objects = new_objects;
    defer w.objects = old_objects;

    sqrt2 := math.sqrt(m.real(2));
    sqrt2_d2 := sqrt2 / 2.0;
    r := m.ray(m.point(0, 0, -3), m.vector(0, -sqrt2_d2, sqrt2_d2));
    i := rt.intersection(sqrt2, &shape);

    comps := rt.hit_info(i, r, nil);
    color := rt.reflected_color(w, &comps);

    expect(t, eq(color, rt.color(0.19033, 0.23791, 0.14274)));
}

@test
Shade_Hit_Reflective_Material :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    shape := rt.plane(m.translation(0, -1, 0), rt.material(reflective=0.5));

    new_objects := []^rt.Shape { w.objects[0], w.objects[1], &shape };
    old_objects := w.objects;
    w.objects = new_objects;
    defer w.objects = old_objects;

    sqrt2 := math.sqrt(m.real(2));
    sqrt2_d2 := sqrt2 / 2.0;
    r := m.ray(m.point(0, 0, -3), m.vector(0, -sqrt2_d2, sqrt2_d2));
    i := rt.intersection(sqrt2, &shape);

    comps := rt.hit_info(i, r, nil);
    color := rt.shade_hit(w, &comps)

    expect(t, eq(color, rt.color(0.87676, 0.92434, 0.82917)));
}

@test
Limit_Reflection_Recursion :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    shape := rt.plane(m.translation(0, -1, 0), rt.material(reflective=0.5));

    new_objects := []^rt.Shape { w.objects[0], w.objects[1], &shape };
    old_objects := w.objects;
    w.objects = new_objects;
    defer w.objects = old_objects;

    sqrt2 := math.sqrt(m.real(2));
    sqrt2_d2 := sqrt2 / 2.0;
    r := m.ray(m.point(0, 0, -3), m.vector(0, -sqrt2_d2, sqrt2_d2));
    i := rt.intersection(sqrt2, &shape);

    comps := rt.hit_info(i, r, nil);
    color := rt.reflected_color(w, &comps, 0)

    expect(t, eq(color, rt.BLACK));
}

@test
Avoid_Infinite_Reflection_Recursion :: proc(t: ^r.Test_Context) {

    light := rt.point_light(m.point(0, 0, 0), rt.WHITE);
    lights := [?]rt.Point_Light { light };

    lower := rt.plane(m.translation(0, -1, 0), rt.material(reflective=1));
    upper := rt.plane(m.translation(0, 1, 0), rt.material(reflective=1));

    objects := [?]^rt.Shape { &lower, &upper };

    r := m.ray(m.point(0, 0, 0), m.vector(0, 1, 0));

    w := rt.world(objects[:], lights[:]);

    rt.color_at(&w, r);
}

@test
Refract_Opaque_Surface :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    shape := w.objects[0];
    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs := rt.intersections(
        rt.intersection(4, shape),
        rt.intersection(6, shape),
    );
    defer delete(xs);

    comps := rt.hit_info(xs[0], r, xs[:]);
    c := rt.refracted_color(w, &comps, 5);

    expect(t, c == rt.BLACK);

}

@test
Refract_Max_Recursion :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    shape := w.objects[0];
    shape.material.transparency = 1.0;
    shape.material.refractive_index = 1.5;

    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs := rt.intersections(
        rt.intersection(4, shape),
        rt.intersection(6, shape),
    );
    defer delete(xs);

    comps := rt.hit_info(xs[0], r, xs[:]);
    c := rt.refracted_color(w, &comps, 0);

    expect(t, c == rt.BLACK);

}

@test
Refract_Total_Internal :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    shape := w.objects[0];
    shape.material.transparency = 1.0;
    shape.material.refractive_index = 1.5;

    sqrt2 := math.sqrt(m.real(2));
    sqrt2_d2 := sqrt2 / 2.0;

    r := m.ray(m.point(0, 0, sqrt2_d2), m.vector(0, 1, 0));

    xs := rt.intersections(
        rt.intersection(-sqrt2_d2, shape),
        rt.intersection(sqrt2_d2, shape),
    );
    defer delete(xs);

    comps := rt.hit_info(xs[1], r, xs[:]);
    c := rt.refracted_color(w, &comps, 5);

    expect(t, c == rt.BLACK);
}

@test
Refracted_Color :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    A := w.objects[0];
    A.material.ambient = 1;
    A_pat := rt.test_pattern();
    A.material.pattern = &A_pat;

    B := w.objects[1];
    B.material.transparency = 1.0;
    B.material.refractive_index = 1.5;

    r := m.ray(m.point(0, 0, 0.1), m.vector(0, 1, 0));

    xs := rt.intersections(
        rt.intersection(-0.9899, A),
        rt.intersection(-0.4899, B),
        rt.intersection(0.4899, B),
        rt.intersection(0.9899, A),
    );
    defer delete(xs);

    comps := rt.hit_info(xs[2], r, xs[:]);
    c := rt.refracted_color(w, &comps, 5);

    expect(t, eq(c, rt.color(0, 0.99887, 0.04722)));
}

@test
Shade_Hit_Transparent_Material :: proc(t: ^r.Test_Context) {

    w := default_world();
    defer destroy_default_world(w);

    new_objects := make([dynamic]^rt.Shape, 0, len(w.objects));
    defer delete(new_objects);
    for o, i in w.objects do append(&new_objects, o);

    floor := rt.plane(m.translation(0, -1, 0));
    floor.material.transparency = 0.5;
    floor.material.refractive_index = 1.5;
    append(&new_objects, &floor);

    ball := rt.sphere(m.translation(0, -3.5, -0.5));
    ball.material.color = rt.color(1, 0, 0);
    ball.material.ambient = 0.5;
    append(&new_objects, &ball);

    old_objects := w.objects;
    w.objects = new_objects[:];
    defer w.objects = old_objects;

    sqrt2 := math.sqrt(m.real(2));
    sqrt2_d2 := sqrt2 / 2.0;

    r := m.ray(m.point(0, 0, -3), m.vector(0, -sqrt2_d2, sqrt2_d2));

    xs := rt.intersections(rt.intersection(sqrt2, &floor));
    defer delete(xs);

    comps := rt.hit_info(xs[0], r, xs[:]);
    color := rt.shade_hit(w, &comps, true, 5);

    expect(t, eq(color, rt.color(0.93642, 0.68642, 0.68642)));
}

package tests_world

import "core:math"

import rt "raytracer:."
import r "raytracer:test_runner"
import m "raytracer:math"

PI :: m.real(math.PI);

shape_suite := r.Test_Suite {
    name = "Shape/",
    tests = {
        r.test("Default_Transform", Default_Transform),
        r.test("Assign_Transform", Assign_Transform),
        r.test("Default_Material", Default_Material),
        r.test("Assign_Material", Assign_Material),
        r.test("Scaled_Intersect", Scaled_Intersect),
        r.test("Translated_Intersect", Translated_Intersect),
        r.test("Translated_Normal", Translated_Normal),
        r.test("Transformed_Normal", Transformed_Normal),

        r.test("Plane_Normal", Plane_Normal),
        r.test("Plane_Intersects_Parallel", Plane_Intersects_Parallel),
        r.test("Plane_Intersects_Coplanar", Plane_Intersects_Coplanar),
        r.test("Plane_Intersects_Above", Plane_Intersects_Above),
        r.test("Plane_Intersects_Below", Plane_Intersects_Below),

        r.test("S_Default_Transform ", S_Default_Transform),
        r.test("S_Modified_Transform", S_Modified_Transform),
        r.test("S_Scaled_Intersect_R", S_Scaled_Intersect_R),
        r.test("S_Normal_X_Axis", S_Normal_X_Axis),
        r.test("S_Normal_Y_Axis", S_Normal_Y_Axis),
        r.test("S_Normal_Z_Axis", S_Normal_Z_Axis),
        r.test("S_Normal_Nonaxial", S_Normal_Nonaxial),
        r.test("S_Normal_Normalized", S_Normal_Normalized),
        r.test("S_Translated_Normal", S_Translated_Normal),
        r.test("S_Scaled_Rotated_Normal", S_Scaled_Rotated_Normal),
        r.test("Sphere_Default_Material", Sphere_Default_Material),
        r.test("Sphere_Modified_Material", Sphere_Modified_Material),

        r.test("Sphere_Glass_Constructor", Sphere_Glass_Constructor),

        r.test("Cube_Intersect", Cube_Intersect),
        r.test("Cube_Miss", Cube_Miss),
        r.test("Cube_Normal", Cube_Normal),

        r.test("Cylinder_Miss", Cylinder_Miss),
        r.test("Cylinder_Hit", Cylinder_Hit),
        r.test("Cylinder_Normal", Cylinder_Normal),
    },
}

@test
Default_Transform :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();

    expect(t, eq(ts.inverse_transform, m.matrix4_identity));
}

@test
Assign_Transform :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();

    rt.set_transform(&ts, m.translation(2, 3, 4));

    expect(t, eq(ts.inverse_transform, m.matrix_inverse(m.translation(2, 3, 4))));
}

@test
Default_Material :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();

    expect(t, ts.material == rt.material());
}

@test
Assign_Material :: proc(t: ^r.Test_Context) {

    m := rt.material(ambient = 1);

    {
        ts := rt.test_shape();
        ts.material = m;
        expect(t, ts.material == m);
    }

    {
        ts := rt.test_shape();
        rt.set_material(&ts, m);
        expect(t, ts.material == m);
    }

}

@test
Scaled_Intersect :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();
    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    rt.set_transform(&ts, m.scaling(2, 2, 2));

    xs := rt.intersects(&ts, r)

    expect(t, eq(ts.saved_ray.origin, m.point(0, 0, -2.5)));
    expect(t, eq(ts.saved_ray.direction, m.vector(0, 0, 0.5)));

}

@test
Translated_Intersect :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();
    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    rt.set_transform(&ts, m.translation(5, 0, 0));

    s := rt.intersects(&ts, r);

    expect(t, eq(ts.saved_ray.origin, m.point(-5, 0, -5)));
    expect(t, eq(ts.saved_ray.direction, m.vector(0, 0, 1)));
}

@test
Translated_Normal :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();

    rt.set_transform(&ts, m.translation(0, 1, 0));
    n := rt.shape_normal_at(&ts, m.point(0, 1.70711, -0.70711));

    expect(t, eq(n, m.vector(0, 0.70711, -0.70711)));
}

@test
Transformed_Normal :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;

    rt.set_transform(&ts, m.scaling(1, 0.5, 1) * m.rotation_z( PI / 5));
    n := rt.shape_normal_at(&ts, m.point(0, sqrt2_over_2, -sqrt2_over_2));

    expect(t, eq(n, m.vector(0, 0.97014, -0.24254)));
}

@test
Plane_Normal :: proc(t: ^r.Test_Context) {

    p := rt.plane();

    n1 := p->normal_at(m.point(0, 0, 0));
    n2 := p->normal_at(m.point(10, 0, -10));
    n3 := p->normal_at(m.point(-5, 0, 150));

    expect(t, eq(n1, m.vector(0, 1, 0)));
    expect(t, eq(n2, m.vector(0, 1, 0)));
    expect(t, eq(n3, m.vector(0, 1, 0)));
}

@test
Plane_Intersects_Parallel :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, 10, 0), m.vector(0, 0, 1));

    xs, ok := p->intersects(r).?;

    expect(t, !ok);
}

@test
Plane_Intersects_Coplanar :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));

    xs, ok := p->intersects(r).?;

    expect(t, !ok);
}

@test
Plane_Intersects_Above :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, 1, 0), m.vector(0, -1, 0));

    xs, ok := p->intersects(r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].object == &p);
    expect(t, xs[1].object == &p);
    expect(t, xs[0] == xs[1]);
}

@test
Plane_Intersects_Below :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, -1, 0), m.vector(0, 1, 0));

    xs, ok := p->intersects(r).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0] == xs[1]);
    expect(t, xs[0].object == &p);
    expect(t, xs[0].t == 1);
}

@test
S_Default_Transform :: proc(t: ^r.Test_Context) {

    s := rt.sphere();

    expect(t, eq(s.inverse_transform, m.matrix4_identity));
}

@test
S_Modified_Transform :: proc(t: ^r.Test_Context) {

    tf := m.translation(2, 3, 4);
    tf_inv := m.matrix_inverse(tf);

    {
        sp := rt.sphere();

        rt.set_transform(&sp, tf);

        expect(t, eq(sp.inverse_transform, tf_inv));
    }

    {
        sp := rt.sphere(tf);

        expect(t, sp.inverse_transform == tf_inv);
    }
}

@test
S_Scaled_Intersect_R :: proc(t: ^r.Test_Context) {

    ray := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));
    sp := rt.sphere(m.scaling(2, 2, 2));

    xs, ok := rt.intersects(&sp, ray).?;

    expect(t, ok);
    expect(t, len(xs) == 2);
    expect(t, xs[0].t == 3);
    expect(t, xs[1].t == 7);

}

@test
S_Normal_X_Axis :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    p := m.point(1, 0, 0);

    // n := rt.normal_at(&sp, p);
    n := sp->normal_at(p);

    expected := m.vector(1, 0, 0);

    expect(t, n == expected);
}

@test
S_Normal_Y_Axis :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    p := m.point(0, 1, 0);

    n := sp->normal_at(p);

    expected := m.vector(0, 1, 0);

    expect(t, n == expected);
}

@test
S_Normal_Z_Axis :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();
    p := m.point(0, 0, 1);

    n := sp->normal_at(p);

    expected := m.vector(0, 0, 1);

    expect(t, n == expected);
}

@test
S_Normal_Nonaxial :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := sp->normal_at(p);

    expected := m.vector(v, v, v);

    expect(t, eq(n, expected));
}

@test
S_Normal_Normalized :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    v := math.sqrt(m.real(3.0)) / 3;
    p := m.point(v, v, v);

    n := sp->normal_at(p);

    expected := m.normalize(n);

    expect(t, eq(n, expected));
}

@test
S_Translated_Normal :: proc(t: ^r.Test_Context) {

    sp := rt.sphere(m.translation(0, 1, 0));

    p := m.point(0, 1.70711, -0.70711);

    n := rt.shape_normal_at(&sp, p);

    expected := m.vector(0, 0.70711, -0.70711);

    expect(t, eq(n, expected));
}

@test
S_Scaled_Rotated_Normal :: proc(t: ^r.Test_Context) {

    sp := rt.sphere(m.scaling(1, 0.5, 1) * m.rotation_z(PI / 5));

    sqrt2_over_2 := math.sqrt(m.real(2.0)) / 2;
    p := m.point(0, sqrt2_over_2, -sqrt2_over_2);

    n := rt.shape_normal_at(&sp, p);

    expected := m.vector(0, 0.97014, -0.24254);

    expect(t, eq(n, expected));
}

@test
Sphere_Default_Material :: proc(t: ^r.Test_Context) {

    sp := rt.sphere();

    m := sp.material;

    expect(t, m == rt.material());
}

@test
Sphere_Modified_Material :: proc(t: ^r.Test_Context) {

    {
        sp := rt.sphere();
        m := rt.material();
        m.ambient = 1;

        rt.set_material(&sp, m);

        expect(t, sp.material == m);
    }

    {
        m := rt.material();
        m.ambient = 1;
        sp := rt.sphere(m);

        expect(t, sp.material == m);
    }

    {
        sp := rt.sphere();
        m := rt.material();
        m.ambient = 1;

        sp.material = m;

        expect(t, sp.material == m);
    }
}

@test
Sphere_Glass_Constructor :: proc(t: ^r.Test_Context) {

    s := rt.glass_sphere();

    expect(t, eq(s.inverse_transform, m.matrix4_identity));
    expect(t, eq(s.material.transparency, 1));
    expect(t, eq(s.material.refractive_index, 1.5));
}

@test
Cube_Intersect :: proc(t: ^r.Test_Context) {

    c := rt.cube();

    Example :: struct {
        origin: m.Point,
        direction: m.Vector,
        t1, t2: m.real,
    }

    examples := [?]Example {
        { m.point(   5, 0.5,  0), m.vector(-1,  0,  0),  4, 6 },
        { m.point(  -5, 0.5,  0), m.vector( 1,  0,  0),  4, 6 },
        { m.point( 0.5,   5,  0), m.vector( 0, -1,  0),  4, 6 },
        { m.point( 0.5,  -5,  0), m.vector( 0,  1,  0),  4, 6 },
        { m.point( 0.5,   0,  5), m.vector( 0,  0, -1),  4, 6 },
        { m.point( 0.5,   0, -5), m.vector( 0,  0,  1),  4, 6 },
        { m.point(   0, 0.5,  0), m.vector( 0,  0,  1), -1, 1 },
    }

    for e, i in examples {
        i := i;
        r := m.ray(e.origin, e.direction);

        xs, ok := c->intersects(r).?

        expect(t, ok);
        expect(t, len(xs) == 2);
        expect(t, xs[0].t == e.t1);
        expect(t, xs[1].t == e.t2);
    }
}

@test
Cube_Miss :: proc(t: ^r.Test_Context) {

    c := rt.cube();

    examples := [?]m.Ray {
        m.ray(m.point(-2,  0,  0), m.vector(0.2673, 0.5345, 0.8018)),
        m.ray(m.point( 0, -2,  0), m.vector(0.8018, 0.2673, 0.5345)),
        m.ray(m.point( 0,  0, -2), m.vector(0.5345, 0.8018, 0.2673)),
        m.ray(m.point( 2,  0,  2), m.vector(     0,      0,     -1)),
        m.ray(m.point( 0,  2,  2), m.vector(     0,     -1,      0)),
        m.ray(m.point( 2,  2,  0), m.vector(    -1,      0,      0)),
    };

    for r in examples {
        xs, ok := c->intersects(r).?;

        expect(t, !ok);
    }
}

@test
Cube_Normal :: proc(t: ^r.Test_Context) {

    c := rt.cube();

    Examle :: struct {
        p: m.Point,
        n: m.Vector,
    }

    examples := [?]Examle {
        { m.point(   1,  0.5, -0.8), m.vector( 1,  0,  0) },
        { m.point(  -1, -0.2,  0.9), m.vector(-1,  0,  0) },
        { m.point(-0.4,    1, -0.1), m.vector( 0,  1,  0) },
        { m.point( 0.3,   -1, -0.7), m.vector( 0, -1,  0) },
        { m.point(-0.6,  0.3,    1), m.vector( 0,  0,  1) },
        { m.point( 0.4,  0.4,   -1), m.vector( 0,  0, -1) },
        { m.point(   1,    1,    1), m.vector( 1,  0,  0) },
        { m.point(  -1,   -1,   -1), m.vector(-1,  0,  0) },
    };


    for e in examples {

        normal := c->normal_at(e.p);

        expect(t, normal == e.n);
    }
}

@test
Cylinder_Miss :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();

    examples := [?]m.Ray {
        m.ray(m.point(1, 0,  0), m.normalize(m.vector(0, 1, 0))),
        m.ray(m.point(0, 0,  0), m.normalize(m.vector(0, 1, 0))),
        m.ray(m.point(0, 0, -5), m.normalize(m.vector(1, 1, 1))),
    }

    for e in examples {

        xs, ok := cyl->intersects(e).?;

        expect(t, !ok);
    }
}

@test
Cylinder_Hit :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();

    Example :: struct {
        ray: m.Ray,
        t0, t1: m.real,
    };

    examples := [?]Example {
        { m.ray(m.point(  1, 0, -5), m.normalize(m.vector(  0, 0, 1))), 5,       5 },
        { m.ray(m.point(  0, 0, -5), m.normalize(m.vector(  0, 0, 1))), 4,       6 },
        { m.ray(m.point(0.5, 0, -5), m.normalize(m.vector(0.1, 1, 1))), 6.80798, 7.08872 },
    };

    for e in examples {

        xs, ok := cyl->intersects(e.ray).?;

        expect(t, len(xs) == 2);
        expect(t, eq(xs[0].t, e.t0));
        expect(t, eq(xs[1].t, e.t1));
    }
}

@test
Cylinder_Normal :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();

    Example :: struct {
        point: m.Point,
        normal: m.Vector,
    };

    examples := [?]Example {
        { m.point(1, 0, 0), m.vector(1, 0, 0) },
        { m.point(0, 5, -1), m.vector(0, 0, -1) },
        { m.point(0, -2, 1), m.vector(0, 0, 1) },
        { m.point(-1, 1, 0), m.vector(-1, 0, 0) },
    };

    for e in examples {

        n := cyl->normal_at(e.point);

        expect(t, eq(n, e.normal));
    }
}

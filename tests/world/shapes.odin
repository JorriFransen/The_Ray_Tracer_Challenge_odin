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
        r.test("Cylinder_Bounds", Cylinder_Bounds),
        r.test("Cylinder_Truncation", Cylinder_Truncation),
        r.test("Cylinder_Closed", Cylinder_Closed),
        r.test("Cylinder_Cap_Intersect", Cylinder_Cap_Intersect),
        r.test("Cylinder_Cap_Normal", Cylinder_Cap_Normal),

        r.test("Cone_Intersect", Cone_Intersect),
        r.test("Cone_Intersect_Parallel", Cone_Intersect_Parallel),
        r.test("Cone_Cap_Intersect", Cone_Cap_Intersect),
        r.test("Cone_Normal", Cone_Normal),

        r.test("Group_Constructor", Group_Constructor),
        r.test("Group_Default_Parent", Group_Default_Parent),
        r.test("Group_Add_Child", Group_Add_Child),
        r.test("Group_Empty_Intersect", Group_Empty_Intersect),
        r.test("Group_Intersect", Group_Intersect),
        r.test("Group_Transformed_Intersect", Group_Transformed_Intersect),
        r.test("Group_Child_Normal", Group_Child_Normal),

        r.test("Shape_Bounds", Shape_Bounds),
        r.test("Bounds_Construction", Bounds_Construction),
        r.test("Parent_Space_Bounds", Parent_Space_Bounds),
        r.test("Bounds_Transform", Bounds_Transform),
        r.test("Group_Bounds", Group_Bounds),
        r.test("Origin_Bounds_Intersect", Origin_Bounds_Intersect),
        r.test("Non_Cubic_Bounds_Intersect", Non_Cubic_Bounds_Intersect),
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

    xs_buf := rt.intersection_buffer(nil);

    xs:= rt.intersects(&ts, r, &xs_buf);

    expect(t, len(xs) == 0);
    expect(t, eq(ts.saved_ray.origin, m.point(0, 0, -2.5)));
    expect(t, eq(ts.saved_ray.direction, m.vector(0, 0, 0.5)));

}

@test
Translated_Intersect :: proc(t: ^r.Test_Context) {

    ts := rt.test_shape();
    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    rt.set_transform(&ts, m.translation(5, 0, 0));

    xs_buf := rt.intersection_buffer(nil);

    s := rt.intersects(&ts, r, &xs_buf);

    expect(t, len(s) == 0);
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

    xs_buf := rt.intersection_buffer(nil);

    xs := p->intersects(r, &xs_buf);

    expect(t, len(xs) == 0);
}

@test
Plane_Intersects_Coplanar :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));

    xs_buf := rt.intersection_buffer(nil);

    xs := p->intersects(r, &xs_buf);

    expect(t, len(xs) == 0);
}

@test
Plane_Intersects_Above :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, 1, 0), m.vector(0, -1, 0));

    xs_buf := rt.intersection_buffer(1, context.temp_allocator);

    xs := p->intersects(r, &xs_buf);

    expect(t, len(xs) == 1);
    expect(t, xs[0].object == &p);
}

@test
Plane_Intersects_Below :: proc(t: ^r.Test_Context) {

    p := rt.plane();
    r := m.ray(m.point(0, -1, 0), m.vector(0, 1, 0));

    xs_buf := rt.intersection_buffer(1, context.temp_allocator);

    xs := p->intersects(r, &xs_buf);

    expect(t, len(xs) == 1);
    expect(t, xs[0].object == &p);
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

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    xs := rt.intersects(&sp, ray, &xs_buf);

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

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    for e, i in examples {
        i := i;
        r := m.ray(e.origin, e.direction);

        xs_buf.count = 0;
        xs := c->intersects(r, &xs_buf)

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

    xs_buf := rt.intersection_buffer(nil);

    for r in examples {

        xs := c->intersects(r, &xs_buf);

        expect(t, len(xs) == 0);
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

    xs_buf := rt.intersection_buffer(nil);

    for e in examples {

        xs := cyl->intersects(e, &xs_buf);

        expect(t, len(xs) == 0);
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

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    for e in examples {

        xs_buf.count = 0;
        xs := cyl->intersects(e.ray, &xs_buf);

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

@test
Cylinder_Bounds :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();

    expect(t, cyl.minimum == -m.INFINITY);
    expect(t, cyl.maximum == m.INFINITY);
}

@test
Cylinder_Truncation :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();
    cyl.minimum = 1;
    cyl.maximum = 2;

    Example :: struct {
        ray: m.Ray,
        count: int,
    };

    examples := [?]Example {
        { m.ray(m.point(0, 1.5,  0), m.normalize(m.vector(0.1, 1, 0))), 0 },
        { m.ray(m.point(0,   3, -5), m.normalize(m.vector(  0, 0, 1))), 0 },
        { m.ray(m.point(0,   0, -5), m.normalize(m.vector(  0, 0, 1))), 0 },
        { m.ray(m.point(0,   2, -5), m.normalize(m.vector(  0, 0, 1))), 0 },
        { m.ray(m.point(0,   1, -5), m.normalize(m.vector(  0, 0, 1))), 0 },
        { m.ray(m.point(0, 1.5, -2), m.normalize(m.vector(  0, 0, 1))), 2 },
    };

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    for e in examples {

        xs := cyl->intersects(e.ray, &xs_buf);

        expect(t, len(xs) == e.count);
    }
}

@test
Cylinder_Closed :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();

    expect(t, cyl.closed == false);
}

@test
Cylinder_Cap_Intersect :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();
    cyl.minimum = 1;
    cyl.maximum = 2;
    cyl.closed = true;

    Example :: struct {
        ray: m.Ray,
        count: int,
    };

    examples := [?]Example {
        { m.ray(m.point(0,  3,  0), m.normalize(m.vector(0, -1, 0))), 2 },
        { m.ray(m.point(0,  3, -2), m.normalize(m.vector(0, -1, 2))), 2 },
        { m.ray(m.point(0,  4, -2), m.normalize(m.vector(0, -1, 1))), 2 },
        { m.ray(m.point(0,  0, -2), m.normalize(m.vector(0,  1, 2))), 2 },
        { m.ray(m.point(0, -1, -2), m.normalize(m.vector(0,  1, 1))), 2 },
    };

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    for e in examples {

        xs_buf.count = 0;
        xs := cyl->intersects(e.ray, &xs_buf);

        expect(t, len(xs) == e.count);
    }
}

@test
Cylinder_Cap_Normal :: proc(t: ^r.Test_Context) {

    cyl := rt.cylinder();
    cyl.minimum = 1;
    cyl.maximum = 2;
    cyl.closed = true;

    Example :: struct {
        point: m.Point,
        normal: m.Vector,
    }

    examples := [?]Example {
        { m.point(  0, 1,   0), m.vector(0, -1, 0) },
        { m.point(0.5, 1,   0), m.vector(0, -1, 0) },
        { m.point(  0, 1, 0.5), m.vector(0, -1, 0) },
        { m.point(  0, 2,   0), m.vector(0,  1, 0) },
        { m.point(0.5, 2,   0), m.vector(0,  1, 0) },
        { m.point(  0, 2, 0.5), m.vector(0,  1, 0) },
    };

    for e in examples {
        n := cyl->normal_at(e.point);

        expect(t, eq(n, e.normal));
    }
}

@test
Cone_Intersect :: proc(t: ^r.Test_Context) {

    shape := rt.cone();

    Example :: struct {
        ray: m.Ray,
        t0, t1: m.real,
    };

    examples := [?]Example {
        { m.ray(m.point(0, 0, -5), m.normalize(m.vector(   0,  0, 1))), 5, 5 },
        { m.ray(m.point(0, 0, -5), m.normalize(m.vector(   1,  1, 1))), 8.66025, 8.66025 },
        { m.ray(m.point(1, 1, -5), m.normalize(m.vector(-0.5, -1, 1))), 4.55006, 49.44994 },
    };

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    for e in examples {

        xs_buf.count = 0;
        xs := shape->intersects(e.ray, &xs_buf);

        expect(t, len(xs) == 2);

        expect(t, eq(xs[0].t, e.t0));
        expect(t, eq(xs[1].t, e.t1));
    }
}

@test
Cone_Intersect_Parallel :: proc(t: ^r.Test_Context) {

    shape := rt.cone();
    direction := m.normalize(m.vector(0, 1, 1));
    r := m.ray(m.point(0, 0, -1), direction);

    xs_buf := rt.intersection_buffer(1, context.temp_allocator);

    xs := shape->intersects(r, &xs_buf);

    expect(t, len(xs) == 1);

    expect(t, xs[0].object == &shape);
    expect(t, eq(xs[0].t, 0.35355));
}

@test
Cone_Cap_Intersect :: proc(t: ^r.Test_Context) {

    shape := rt.cone();
    shape.minimum = -0.5;
    shape.maximum = 0.5;
    shape.closed = true;

    Example :: struct {
        ray: m.Ray,
        count: int,
    };

    examples := [?]Example {
        { m.ray(m.point(0, 0,    -5), m.normalize(m.vector(0, 1, 0))), 0 },
        { m.ray(m.point(0, 0, -0.25), m.normalize(m.vector(0, 1, 1))), 2 },
        { m.ray(m.point(0, 0, -0.25), m.normalize(m.vector(0, 1, 0))), 4 },
    };

    xs_buf := rt.intersection_buffer(4, context.temp_allocator);

    for e in examples {

        xs_buf.count = 0;
        xs := shape->intersects(e.ray, &xs_buf);

        expect(t, len(xs) == e.count);
    }

}

@test
Cone_Normal :: proc(t: ^r.Test_Context) {

    shape := rt.cone();

    Example :: struct {
        point: m.Point,
        normal: m.Vector,
    };

    examples := [?]Example {
        { m.point( 0,  0, 0), m.vector( 0,                     0, 0) },
        { m.point( 1,  1, 1), m.vector( 1, -math.sqrt(m.real(2)), 1) },
        { m.point(-1, -1, 0), m.vector(-1,                     1, 0) },
    };

    for e in examples {

        n := shape->normal_at(e.point);

        expect(t, eq(n, e.normal));
    }

}

@test
Group_Constructor :: proc(t: ^r.Test_Context) {

    g := rt.group();

    expect(t, eq(g.inverse_transform, m.matrix4_identity));
    expect(t, len(g.shapes) == 0);
}

@test
Group_Default_Parent :: proc(t: ^r.Test_Context) {

    s := rt.test_shape();

    expect(t, s.parent == nil);
}

@test
Group_Add_Child :: proc(t: ^r.Test_Context) {

    g := rt.group();
    defer rt.delete_group(&g);

    s := rt.test_shape();

    rt.group_add_child(&g, &s);

    expect(t, len(g.shapes) == 1);
    expect(t, g.shapes[0] == &s);
    expect(t, s.parent == &g);


}

@test
Group_Empty_Intersect :: proc(t: ^r.Test_Context) {

    g := rt.group();
    defer rt.delete_group(&g);

    r := m.ray(m.point(0, 0, 0), m.vector(0, 0, 1));

    xs_buf := rt.intersection_buffer(nil);

    xs := g->intersects(r, &xs_buf);

    expect(t, len(xs) == 0);
}

@test
Group_Intersect :: proc(t: ^r.Test_Context) {

    g := rt.group();
    defer rt.delete_group(&g);

    s1 := rt.sphere();
    s2 := rt.sphere(m.translation(0, 0, -3));
    s3 := rt.sphere(m.translation(5, 0, 0));

    rt.group_add_child(&g, &s1);
    rt.group_add_child(&g, &s2);
    rt.group_add_child(&g, &s3);

    r := m.ray(m.point(0, 0, -5), m.vector(0, 0, 1));

    xs_buf := rt.intersection_buffer(4, context.temp_allocator);

    xs := g->intersects(r, &xs_buf);

    expect(t, len(xs) == 4);

    expect(t, xs[0].object == &s2);
    expect(t, xs[1].object == &s2);
    expect(t, xs[2].object == &s1);
    expect(t, xs[3].object == &s1);
}

@test
Group_Transformed_Intersect :: proc(t: ^r.Test_Context) {

    g := rt.group(m.scaling(2, 2, 2));
    defer rt.delete_group(&g);

    s := rt.sphere(m.translation(5, 0, 0));

    rt.group_add_child(&g, &s);

    r := m.ray(m.point(10, 0, -10), m.vector(0, 0, 1));

    xs_buf := rt.intersection_buffer(2, context.temp_allocator);

    xs := rt.intersects(&g, r, &xs_buf);

    expect(t, len(xs) == 2);
    expect(t, xs[0].object == &s);
    expect(t, xs[1].object == &s);
}

@test
Group_Child_Normal :: proc(t: ^r.Test_Context) {

    g1 := rt.group(m.rotation_y(PI / 2));
    defer rt.delete_group(&g1);

    g2 := rt.group(m.scaling(1, 2, 3));
    defer rt.delete_group(&g2);

    rt.group_add_child(&g1, &g2);

    s := rt.sphere(m.translation(5, 0, 0));
    rt.group_add_child(&g2, &s);

    n := rt.shape_normal_at(&s, m.point(1.7321, 1.1547, -5.5774));

    expect(t, eq(n, m.vector(0.28570, 0.42854, -0.85716)));

}

@test
Shape_Bounds :: proc(t: ^r.Test_Context) {

    {
        s := rt.sphere();
        assert(s.vtable.get_bounds != nil);
        b := s->get_bounds();
        expected := rt.Bounds { m.point(-1, -1, -1), m.point(1, 1, 1) };
        expect(t, b == expected);
    }

    {
        p := rt.plane();
        assert(p.vtable.get_bounds != nil);
        b := p->get_bounds();
        expected := rt.Bounds { m.point(-m.INFINITY, 0, -m.INFINITY), m.point(m.INFINITY, 0, m.INFINITY) };
        expect(t, b == expected);
    }

    {
        c := rt.cube();
        assert(c.vtable.get_bounds != nil);
        b := c->get_bounds();
        expected := rt.Bounds { m.point(-1, -1, -1), m.point(1, 1, 1) };
        expect(t, b == expected);
    }

    {
        cyl1 := rt.cylinder();
        assert(cyl1.vtable.get_bounds != nil);
        b := cyl1->get_bounds();
        expected := rt.Bounds { m.point(-1, -m.INFINITY, -1), m.point(1, m.INFINITY, 1) };
        expect(t, b == expected);

        cyl2 := rt.cylinder();
        cyl2.minimum = -5;
        cyl2.maximum = 3;
        b = cyl2->get_bounds();
        expected = rt.Bounds { m.point(-1, -5, -1), m.point(1, 3, 1) };
        expect(t, b == expected);
    }

    {
        cone1 := rt.cone();
        assert(cone1.vtable.get_bounds != nil);
        b := cone1->get_bounds();
        expected := rt.Bounds { m.point(-m.INFINITY, -m.INFINITY, -m.INFINITY), m.point(m.INFINITY, m.INFINITY, m.INFINITY) };
        expect(t, b == expected);

        cone2 := rt.cone();
        cone2.minimum = -5;
        cone2.maximum = 3;
        b = cone2->get_bounds();
        expected = rt.Bounds { m.point(-5, -5, -5), m.point(5, 3, 5) };
        expect(t, b == expected);
    }

    {
        ts := rt.test_shape();
        assert(ts.vtable.get_bounds != nil);
        b := ts->get_bounds();
        expected := rt.Bounds { m.point(-1, -1, -1), m.point(1, 1, 1) };
        expect(t, b == expected);
    }
}


@test
Bounds_Construction :: proc(t: ^r.Test_Context) {

    {
        b := rt.bounds();

        expect(t, eq(b.min, m.point(m.INFINITY, m.INFINITY, m.INFINITY)));
        expect(t, eq(b.max, m.point(-m.INFINITY, -m.INFINITY, -m.INFINITY)));
    }

    {
        b := rt.bounds(m.point(-1, -2, -3), m.point(3, 2, 1));

        expect(t, eq(b.min, m.point(-1, -2, -3)));
        expect(t, eq(b.max, m.point(3, 2, 1)));
    }

    {
        b := rt.bounds();
        b = rt.bounds(b, m.point(-5, 2, 0));
        b = rt.bounds(b, m.point(7, 0, -3));

        expect(t, eq(b.min, m.point(-5, 0, -3)));
        expect(t, eq(b.max, m.point(7, 2, 0)));
    }

    {
        b1 := rt.bounds(m.point(-5, -2, 0), m.point(7, 4, 4));
        b2 := rt.bounds(m.point(8, -7, -2), m.point(14, 2, 8));

        b1 = rt.bounds(b1, b2);

        expect(t, eq(b1.min, m.point(-5, -7, -2)));
        expect(t, eq(b1.max, m.point(14, 4, 8)));
    }
}

@test
Parent_Space_Bounds :: proc(t: ^r.Test_Context) {

    g := rt.group();
    defer rt.delete_group(&g);

    shape := rt.sphere(m.translation(1, -3, 5) * m.scaling(0.5, 2, 4));
    b := rt.parent_space_bounds(&shape);

    expect(t, eq(b.min, m.point(0.5, -5, 1)));
    expect(t, eq(b.max, m.point(1.5, -1, 9)));
}

@test
Bounds_Transform :: proc(t: ^r.Test_Context) {

    b := rt.bounds(m.point(-1, -1, -1), m.point(1, 1, 1));
    mat := m.rotation_x(PI / 4) * m.rotation_y(PI / 4);

    b2 := rt.bounds_transform(b, mat);

    expect(t, eq(b2.min, m.point(-1.41421, -1.70711, -1.70711)));
    expect(t, eq(b2.max, m.point(1.41421, 1.70711, 1.70711)));
}

@test
Group_Bounds :: proc(t: ^r.Test_Context) {

    s := rt.sphere(m.translation(2, 5, -3) * m.scaling(2, 2, 2));
    c := rt.cylinder(m.translation(-4, -1, 4) * m.scaling(0.5, 1, 0.5));
    c.minimum = -2;
    c.maximum = 2;

    g := rt.group();
    defer rt.delete_group(&g);

    rt.group_add_child(&g, &s);
    rt.group_add_child(&g, &c);

    assert(g.vtable.get_bounds != nil);

    b := g->get_bounds();

    expect(t, eq(b.min, m.point(-4.5, -3, -5)));
    expect(t, eq(b.max, m.point(4, 7, 4.5)));
}

@test
Origin_Bounds_Intersect :: proc(t: ^r.Test_Context) {

    Example :: struct {
        origin: m.Point,
        direction: m.Vector,
        result: bool,
    };

    examples := [?]Example {
        { m.point(  5, 0.5,  0), m.normalize(m.vector(-1,  0,  0)),  true },
        { m.point( -5, 0.5,  0), m.normalize(m.vector( 1,  0,  0)),  true },
        { m.point(0.5,   5,  0), m.normalize(m.vector( 0, -1,  0)),  true },
        { m.point(0.5,  -5,  0), m.normalize(m.vector( 0,  1,  0)),  true },
        { m.point(0.5,   0,  5), m.normalize(m.vector( 0,  0, -1)),  true },
        { m.point(0.5,   0, -5), m.normalize(m.vector( 0,  0,  1)),  true },
        { m.point(  0, 0.5,  0), m.normalize(m.vector( 0,  0,  1)),  true },
        { m.point( -2,   0,  0), m.normalize(m.vector( 2,  4,  6)), false },
        { m.point(  0,  -2,  0), m.normalize(m.vector( 6,  2,  4)), false },
        { m.point(  0,   0, -2), m.normalize(m.vector( 4,  6,  2)), false },
        { m.point(  2,   0,  2), m.normalize(m.vector( 0,  0, -1)), false },
        { m.point(  0,   2,  2), m.normalize(m.vector( 0, -1,  0)), false },
        { m.point(  2,   2,  0), m.normalize(m.vector(-1,  0,  0)), false },
    };

    b := rt.bounds(m.point(-1, -1, -1), m.point(1, 1, 1));

    for e in examples {

        r := m.ray(e.origin, e.direction);

        expect(t, rt.bounds_intersect(b, r) == e.result);
    }
}

@test
Non_Cubic_Bounds_Intersect :: proc(t: ^r.Test_Context) {

    Example :: struct {
        origin: m.Point,
        direction: m.Vector,
        result: bool,
    };

    examples := [?]Example {
        { m.point(15,  1,   2), m.normalize(m.vector(-1,  0,  0)),  true },
        { m.point(-5, -1,   4), m.normalize(m.vector( 1,  0,  0)),  true },
        { m.point( 7,  6,   5), m.normalize(m.vector( 0, -1,  0)),  true },
        { m.point( 9, -5,   6), m.normalize(m.vector( 0,  1,  0)),  true },
        { m.point( 8,  2,  12), m.normalize(m.vector( 0,  0, -1)),  true },
        { m.point( 6,  0,  -5), m.normalize(m.vector( 0,  0,  1)),  true },
        { m.point( 8,  1, 3.5), m.normalize(m.vector( 0,  0,  1)),  true },
        { m.point( 9, -1,  -8), m.normalize(m.vector( 2,  4,  6)), false },
        { m.point( 8,  3,  -4), m.normalize(m.vector( 6,  2,  4)), false },
        { m.point( 9, -1,  -2), m.normalize(m.vector( 4,  6,  2)), false },
        { m.point( 4,  0,   9), m.normalize(m.vector( 0,  0, -1)), false },
        { m.point( 8,  6,  -1), m.normalize(m.vector( 0, -1,  0)), false },
        { m.point(12,  5,   4), m.normalize(m.vector(-1,  0,  0)), false },
    };

    b := rt.bounds(m.point(5, -2, 0), m.point(11, 4, 7));

    for e in examples {

        r := m.ray(e.origin, e.direction);

        expect(t, rt.bounds_intersect(b, r) == e.result);
    }
}

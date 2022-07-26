package tests

import rt "raytracer:."
import m "raytracer:math"
import r "raytracer:test_runner"

pattern_suite := r.Test_Suite {
    name = "Pattern/",
    tests = {
        r.test("Construct_Stripe", Construct_Stripe),
        r.test("Stripe_Constant_Y", Stripe_Constant_Y),
        r.test("Stripe_Constant_Z", Stripe_Constant_Z),
        r.test("Stripe_Alternates_X", Stripe_Alternates_X),
        r.test("Stripe_Object_Transform", Stripe_Object_Transform),
        r.test("Stripe_Pattern_Transform", Stripe_Pattern_Transform),
        r.test("Stripe_Object_Pattern_Transform", Stripe_Object_Pattern_Transform),
        r.test("Default_Transformation", Default_Transformation),
        r.test("Assigned_Transformation", Assigned_Transformation),
        r.test("Object_Transform", Object_Transform),
        r.test("Pattern_Transform", Pattern_Transform),
        r.test("Object_Pattern_Transform", Object_Pattern_Transform),
        r.test("Gradient_Is_Linear", Gradient_Is_Linear),
        r.test("Ring_Extends_XZ", Ring_Extends_XZ),
        r.test("Checkers_Repeat_X", Checkers_Repeat_X),
        r.test("Checkers_Repeat_Y", Checkers_Repeat_Y),
        r.test("Checkers_Repeat_Z", Checkers_Repeat_Z),
    },
}

@test
Construct_Stripe :: proc(t: ^r.Test_Context) {

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    expect(t, pattern.a == rt.WHITE);
    expect(t, pattern.b == rt.BLACK);
}

@test
Stripe_Constant_Y :: proc(t: ^r.Test_Context) {

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 1, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 2, 0)), rt.WHITE));
}

@test
Stripe_Constant_Z :: proc(t: ^r.Test_Context) {

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 0, 1)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 0, 2)), rt.WHITE));
}

@test
Stripe_Alternates_X :: proc(t: ^r.Test_Context) {

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0.9, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(1, 0, 0)), rt.BLACK));
    expect(t, eq(pattern->pattern_at(m.point(-0.1, 0, 0)), rt.BLACK));
    expect(t, eq(pattern->pattern_at(m.point(-1, 0, 0)), rt.BLACK));
    expect(t, eq(pattern->pattern_at(m.point(-1.1, 0, 0)), rt.WHITE));
}

@test
Stripe_Object_Transform :: proc(t: ^r.Test_Context) {

    object := rt.sphere(m.scaling(2, 2, 2));
    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    c := rt.pattern_at_shape(&pattern, &object, m.point(1.5, 0, 0));

    expect(t, eq(c, rt.WHITE));
}

@test
Stripe_Pattern_Transform :: proc(t: ^r.Test_Context) {

    object := rt.sphere();

    {
        pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);
        rt.set_pattern_transform(&pattern, m.scaling(2, 2, 2));

        c := rt.pattern_at_shape(&pattern, &object, m.point(1.5, 0, 0));

        expect(t, eq(c, rt.WHITE));
    }

    {
        pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK, m.scaling(2, 2, 2));

        c := rt.pattern_at_shape(&pattern, &object, m.point(1.5, 0, 0));

        expect(t, eq(c, rt.WHITE));
    }
}

@test
Stripe_Object_Pattern_Transform :: proc(t: ^r.Test_Context) {

    object := rt.sphere(m.scaling(2, 2, 2));

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);
    rt.set_pattern_transform(&pattern, m.translation(0.5, 0, 0));

    c := rt.pattern_at_shape(&pattern, &object, m.point(2.5, 0, 0));

    expect(t, eq(c, rt.WHITE));
}

@test
Default_Transformation :: proc(t: ^r.Test_Context) {

    pattern := rt.test_pattern();

    expect(t, eq(pattern.inverse_transform, m.matrix4_identity));
}

@test
Assigned_Transformation :: proc(t: ^r.Test_Context) {

    pattern := rt.test_pattern();
    rt.set_pattern_transform(&pattern, m.translation(1, 2, 3));

    expect(t, eq(pattern.inverse_transform, m.matrix_inverse(m.translation(1, 2, 3))));
}

@test
Object_Transform :: proc(t: ^r.Test_Context) {

    shape := rt.sphere(m.scaling(2, 2, 2));
    pattern := rt.test_pattern();

    c := rt.pattern_at_shape(&pattern, &shape, m.point(2, 3, 4));

    expect(t, eq(c, rt.color(1, 1.5, 2)));
}

@test
Pattern_Transform :: proc(t: ^r.Test_Context) {

    shape := rt.sphere();
    pattern := rt.test_pattern();
    rt.set_pattern_transform(&pattern, m.scaling(2, 2, 2));

    c := rt.pattern_at_shape(&pattern, &shape, m.point(2, 3, 4));

    expect(t, eq(c, rt.color(1, 1.5, 2)));
}

@test
Object_Pattern_Transform :: proc(t: ^r.Test_Context) {

    shape := rt.sphere(m.scaling(2, 2, 2));
    pattern := rt.test_pattern();
    rt.set_pattern_transform(&pattern, m.translation(0.5, 1, 1.5));

    c := rt.pattern_at_shape(&pattern, &shape, m.point(2.5, 3, 3.5));

    expect(t, eq(c, rt.color(0.75, 0.5, 0.25)));
}

@test
Gradient_Is_Linear :: proc(t: ^r.Test_Context) {

    pattern := rt.gradient_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0.25, 0, 0)), rt.color(0.75, 0.75, 0.75)));
    expect(t, eq(pattern->pattern_at(m.point(0.5, 0, 0)), rt.color(0.5, 0.5, 0.5)));
    expect(t, eq(pattern->pattern_at(m.point(.75, 0, 0)), rt.color(0.25, 0.25, 0.25)));
}

@test
Ring_Extends_XZ :: proc(t: ^r.Test_Context) {

    pattern := rt.ring_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(1, 0, 0)), rt.BLACK));
    expect(t, eq(pattern->pattern_at(m.point(0, 0, 1)), rt.BLACK));
    // 0.708 = just slihtly more than sqrt(2)/2
    expect(t, eq(pattern->pattern_at(m.point(0.708, 0, 0.708)), rt.BLACK));
}

@test
Checkers_Repeat_X :: proc(t: ^r.Test_Context) {

    pattern := rt.checkers_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0.99, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(1.01, 0, 0)), rt.BLACK));
}

@test
Checkers_Repeat_Y :: proc(t: ^r.Test_Context) {

    pattern := rt.checkers_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 0.99, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 1.01, 0)), rt.BLACK));
}

@test
Checkers_Repeat_Z :: proc(t: ^r.Test_Context) {

    pattern := rt.checkers_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 0, 0.99)), rt.WHITE));
    expect(t, eq(pattern->pattern_at(m.point(0, 0, 1.01)), rt.BLACK));
}

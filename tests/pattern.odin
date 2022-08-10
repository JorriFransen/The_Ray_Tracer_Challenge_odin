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
    },
}

@test
Construct_Stripe :: proc(t: ^r.Test_Context) {

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    expect(t, eq(pattern.a, rt.WHITE));
    expect(t, eq(pattern.b, rt.BLACK));
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

    sb : rt.Shapes(1);
    object := rt.sphere(&sb, m.scaling(2, 2, 2));
    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);

    c := rt.pattern_at_shape(&pattern, object, m.point(1.5, 0, 0));

    expect(t, eq(c, rt.WHITE));
}

@test
Stripe_Pattern_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    object := rt.sphere(&sb);

    {
        pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);
        rt.set_pattern_transform(&pattern, m.scaling(2, 2, 2));

        c := rt.pattern_at_shape(&pattern, object, m.point(1.5, 0, 0));

        expect(t, eq(c, rt.WHITE));
    }

    {
        pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK, m.scaling(2, 2, 2));

        c := rt.pattern_at_shape(&pattern, object, m.point(1.5, 0, 0));

        expect(t, eq(c, rt.WHITE));
    }
}

@test
Stripe_Object_Pattern_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    object := rt.sphere(&sb, m.scaling(2, 2, 2));

    pattern := rt.stripe_pattern(rt.WHITE, rt.BLACK);
    rt.set_pattern_transform(&pattern, m.translation(0.5, 0, 0));

    c := rt.pattern_at_shape(&pattern, object, m.point(2.5, 0, 0));

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

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb, m.scaling(2, 2, 2));
    pattern := rt.test_pattern();

    c := rt.pattern_at_shape(&pattern, shape, m.point(2, 3, 4));

    expect(t, eq(c, rt.color(1, 1.5, 2)));
}

@test
Pattern_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb);
    pattern := rt.test_pattern();
    rt.set_pattern_transform(&pattern, m.scaling(2, 2, 2));

    c := rt.pattern_at_shape(&pattern, shape, m.point(2, 3, 4));

    expect(t, eq(c, rt.color(1, 1.5, 2)));
}

@test
Object_Pattern_Transform :: proc(t: ^r.Test_Context) {

    sb : rt.Shapes(1);
    shape := rt.sphere(&sb, m.scaling(2, 2, 2));
    pattern := rt.test_pattern();
    rt.set_pattern_transform(&pattern, m.translation(0.5, 1, 1.5));

    c := rt.pattern_at_shape(&pattern, shape, m.point(2.5, 3, 3.5));

    expect(t, eq(c, rt.color(0.75, 0.5, 0.25)));
}

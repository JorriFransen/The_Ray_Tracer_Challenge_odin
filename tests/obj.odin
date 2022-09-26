package tests

import rt "raytracer:."
import r "raytracer:test_runner"
import m "raytracer:math"

obj_suite := r.Test_Suite {
    name = "OBJ_Parser/",
    tests = {
        r.test("Ignore_Invalid_Command", Ignore_Invalid_Command),
        r.test("Vertex_Records", Vertex_Records),
        r.test("Parsing_Triangle_Faces", Parsing_Triangle_Faces),
        r.test("Triangulating_Polygons", Triangulating_Polygons),
        r.test("Triangles_In_Groups", Triangles_In_Groups),
        r.test("OBJ_To_Group", OBJ_To_Group),
    },
};

import "core:fmt"

@test
Ignore_Invalid_Command :: proc(t: ^r.Test_Context) {

    gibberish ::
        `There was a young lady named Bright
        who raveled much faster than light.
        She set out one day
        in a relative way,
        and came back the preious night.`;

    parsed_obj, parse_ok  := rt.parse_obj_string(gibberish);
    expect(t, parse_ok);
    if !parse_ok do return;
    defer rt.free_parsed_obj_file(&parsed_obj);

    expect(t, parsed_obj.ignored_line_count == 5);

}

@test
Vertex_Records :: proc(t: ^r.Test_Context) {

    file_content :: `
        v -1 1 0
        v -1.0000 0.5000 0.0000
        v 1 0 0
        v 1 1 0
    `;

    parsed_obj, parse_ok := rt.parse_obj_string(file_content);
    expect(t, parse_ok);
    if !parse_ok do return;
    defer rt.free_parsed_obj_file(&parsed_obj);

    expect(t, len(parsed_obj.vertices) == 4);

    expect(t, eq(parsed_obj.vertices[0], m.point(-1, 1, 0)));
    expect(t, eq(parsed_obj.vertices[1], m.point(-1, 0.5, 0)));
    expect(t, eq(parsed_obj.vertices[2], m.point(1, 0, 0)));
    expect(t, eq(parsed_obj.vertices[3], m.point(1, 1, 0)));
}

@test
Parsing_Triangle_Faces :: proc(t: ^r.Test_Context) {

    file_content :: `
        v -1 1 0
        v -1 0 0
        v 1 0 0
        v 1 1 0

        f 1 2 3
        f 1 3 4
    `;

    parsed_obj, parse_ok := rt.parse_obj_string(file_content, true);
    expect(t, parse_ok);
    if !parse_ok do return;
    defer rt.free_parsed_obj_file(&parsed_obj);

    g := rt.obj_get_default_group(&parsed_obj);

    expect(t, len(g.shapes) == 2);
    if len(g.shapes) != 2 do return;

    t1 := transmute(^rt.Triangle)g.shapes[0];
    t2 := transmute(^rt.Triangle)g.shapes[1];

    expect(t, t1.p1 == parsed_obj.vertices[0]);
    expect(t, t1.p2 == parsed_obj.vertices[1]);
    expect(t, t1.p3 == parsed_obj.vertices[2]);

    expect(t, t2.p1 == parsed_obj.vertices[0]);
    expect(t, t2.p2 == parsed_obj.vertices[2]);
    expect(t, t2.p3 == parsed_obj.vertices[3]);
}

@test
Triangulating_Polygons :: proc(t: ^r.Test_Context) {

    file_content :: `
        v -1 1 0
        v -1 0 0
        v 1 0 0
        v 1 1 0
        v 0 2 0

        f 1 2 3 4 5
    `;

    parsed_obj, parse_ok := rt.parse_obj_string(file_content, true);
    expect(t, parse_ok);
    if !parse_ok do return;
    defer rt.free_parsed_obj_file(&parsed_obj);

    g := rt.obj_get_default_group(&parsed_obj);

    expect(t, len(g.shapes) == 3);
    if len(g.shapes) != 3 do return;

    t1 := transmute(^rt.Triangle)g.shapes[0];
    t2 := transmute(^rt.Triangle)g.shapes[1];
    t3 := transmute(^rt.Triangle)g.shapes[2];

    expect(t, t1.p1 == parsed_obj.vertices[0]);
    expect(t, t1.p2 == parsed_obj.vertices[1]);
    expect(t, t1.p3 == parsed_obj.vertices[2]);

    expect(t, t2.p1 == parsed_obj.vertices[0]);
    expect(t, t2.p2 == parsed_obj.vertices[2]);
    expect(t, t2.p3 == parsed_obj.vertices[3]);

    expect(t, t3.p1 == parsed_obj.vertices[0]);
    expect(t, t3.p2 == parsed_obj.vertices[3]);
    expect(t, t3.p3 == parsed_obj.vertices[4]);

}

@test
Triangles_In_Groups :: proc(t: ^r.Test_Context) {

    parsed_obj, parse_ok := rt.parse_obj_file("tests/triangles.obj", true);
    expect(t, parse_ok);
    if !parse_ok do return;
    defer rt.free_parsed_obj_file(&parsed_obj);

    g1 := rt.obj_get_named_group(&parsed_obj, "FirstGroup");
    expect(t, g1 != nil);
    g2 := rt.obj_get_named_group(&parsed_obj, "SecondGroup");
    expect(t, g2 != nil);

    expect(t, len(g1.shapes) == 1);
    if len(g1.shapes) != 1 do return;
    expect(t, len(g2.shapes) == 1);
    if len(g2.shapes) != 1 do return;

    t1 := transmute(^rt.Triangle)g1.shapes[0];
    t2 := transmute(^rt.Triangle)g2.shapes[0];

    expect(t, t1.p1 == parsed_obj.vertices[0]);
    expect(t, t1.p2 == parsed_obj.vertices[1]);
    expect(t, t1.p3 == parsed_obj.vertices[2]);
    expect(t, t2.p1 == parsed_obj.vertices[0]);
    expect(t, t2.p2 == parsed_obj.vertices[2]);
    expect(t, t2.p3 == parsed_obj.vertices[3]);
}

@test
OBJ_To_Group :: proc(t: ^r.Test_Context) {

    parsed_obj, parse_ok := rt.parse_obj_file("tests/triangles.obj", true);
    expect(t, parse_ok);
    if !parse_ok do return;
    defer rt.free_parsed_obj_file(&parsed_obj); // The group from 'obj_to_group' references shapes (triangles/groups) owned by the parsed_obj, so we can only free it when we are done with the group from 'obj_to_group'.

    g := rt.obj_to_group(&parsed_obj);
    defer { rt.delete_group(g); free(g); }

    should_contain := []^rt.Group {
        rt.obj_get_named_group(&parsed_obj, "FirstGroup"),
        rt.obj_get_named_group(&parsed_obj, "SecondGroup"),
    };

    for eg in should_contain {
        expect(t, eg != nil);

        found := false;

        for c in g.shapes {
            if c == eg {
                found = true;
                break;
            }
        }

        expect(t, found);
    }

}

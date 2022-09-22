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

    parsed_obj := rt.parse_obj_string(gibberish);
    defer rt.free_parsed_obj_file(&parsed_obj);

    // Valid means we parsed successfully, not that the file matches the spec.
    // (We ignore lines that don't start with a valid command.)
    expect(t, parsed_obj.valid);

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

    parsed_obj := rt.parse_obj_string(file_content);
    defer rt.free_parsed_obj_file(&parsed_obj);

    expect(t, parsed_obj.valid);

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

    parsed_obj := rt.parse_obj_string(file_content, true);
    defer rt.free_parsed_obj_file(&parsed_obj);

    expect(t, parsed_obj.group != nil);
    if parsed_obj.group == nil do return;

    g := parsed_obj.group;

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

package raytracer

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import m "raytracer:math"

Parsed_Obj_File :: struct {
    ignored_line_count : int,

    vertices : []m.Point,
    normals : []m.Vector,
    triangles : []Triangle,
    smooth_triangles : []Smooth_Triangle,

    groups : []Group,
    group_names : []string,

};

@(private="file")
Obj_Parse_Context :: struct {
    current_triangle: int,
    current_smooth_triangle: int,
}

@(private="file")
Face :: struct {
    indices: [dynamic]u64,
    normals: [dynamic]u64,
    group: ^Group,
};

obj_get_default_group :: proc(parsed_obj: ^Parsed_Obj_File) -> ^Group {

    assert(len(parsed_obj.groups) >= 1);
    return &parsed_obj.groups[0];
}

obj_get_named_group :: proc(parsed_obj: ^Parsed_Obj_File, name: string) -> ^Group {

    if len(parsed_obj.group_names) <= 0 do return nil;

    for n, i in parsed_obj.group_names {
        if n == name {
            return &parsed_obj.groups[i + 1];
        }
    }

    return nil;
}

obj_to_group_o :: proc(parsed_obj: ^Parsed_Obj_File) -> ^Group {

    return obj_to_group_o_m(parsed_obj, material());
}

obj_to_group_o_m :: proc(parsed_obj: ^Parsed_Obj_File, material: Material) -> ^Group {

    assert(len(parsed_obj.groups) > 0);

    g := new(Group);
    g^ = group();

    for i := 0; i < len(parsed_obj.groups); i += 1 {

        if len(parsed_obj.groups[i].shapes) > 0 {
            group_add_child(g, &parsed_obj.groups[i]);
            obj_apply_material(&parsed_obj.groups[i], material);
        }

    }

    return g;
}

obj_to_group :: proc {
    obj_to_group_o,
    obj_to_group_o_m,
}

@(private="file")
obj_apply_material :: proc(group: ^Group, material: Material) {

    for c in group.shapes {

        // Only group has this function
        if c.vtable.child_count != nil {
            obj_apply_material(group, material);
        } else {
            set_material(c, material);
        }

    }
}

parse_obj_file :: proc(path: string, warn := false) -> (Parsed_Obj_File, bool) {

    if !os.is_file(path) {
        fmt.fprintf(os.stderr, "OBJ Parse Error: not a file: '%v'\n", path);
        return {}, false;
    }

    file_content, read_ok := os.read_entire_file(path);
    assert(read_ok);
    defer delete(file_content);

    return parse_obj_string(string(file_content), warn);
}

parse_obj_string :: proc(obj_str_: string, warn := false) -> (result: Parsed_Obj_File, ok: bool) {

    obj_str := obj_str_;

    current_line := 0;
    vertex_count, vertex_normal_count, face_count := 0, 0, 0;
    group_count := 1; // Always add the root group

    pc := Obj_Parse_Context {};

    // First pass, gather vertex and face count
    for _line in strings.split_lines_iterator(&obj_str) {
        line := _line;
        current_line += 1;

        line = strings.trim_left_space(line);

        if len(line) <= 1 {
            continue;
        }

        if strings.has_prefix(line, "v ") {
            vertex_count += 1;
        } else if strings.has_prefix(line, "vn ") {
            vertex_normal_count += 1;
        } else if strings.has_prefix(line, "f ") {
            face_count += 1;
        } else if strings.has_prefix(line, "g ") {
            group_count += 1;
        }
    }

    result.groups = make([]Group, group_count);
    for g in &result.groups {
        g = group();
    }

    result.group_names = make([]string, group_count - 1);

    ok = false;
    result.vertices = make([]m.Point, vertex_count);
    result.normals = make([]m.Vector, vertex_normal_count);

    faces : []Face;

    if face_count > 0 {

        faces = make([]Face, face_count, context.temp_allocator);

        for f in &faces {
            f.indices = make([dynamic]u64, 0, 3, context.temp_allocator);
            f.normals = make([dynamic]u64, 0, 3, context.temp_allocator);
            f.group = &result.groups[0];
        }
    }

    current_line = 0;
    current_vertex := 0;
    current_normal := 0;
    current_face := 0;
    current_group_name := 0;

    // Second pass, store vertices and faces
    obj_str = obj_str_;
    for _line in strings.split_lines_iterator(&obj_str) {
        line := _line;

        current_line += 1;

        line = strings.trim_left_space(line);

        if len(line) <= 1 {
            continue;
        }

        if strings.has_prefix(line, "v ") {
            line = line[2:];
            vertex_coords := strings.trim_left_space(line);

            vertex := parse_point(vertex_coords, &current_line) or_return;

            result.vertices[current_vertex] = vertex;
            current_vertex += 1;

        } else if strings.has_prefix(line, "vn ") {

            line = line[3:];
            vertex_normals := strings.trim_left_space(line);

            normal := parse_vector(vertex_normals, &current_line) or_return;

            result.normals[current_normal] = normal;
            current_normal += 1;

        } else if strings.has_prefix(line, "f ") {

            line = line[2:];
            indices_str := strings.trim_left_space(line);

            face := &faces[current_face];

            for index_tuple_str_ in strings.split_iterator(&indices_str, " ") {

                index_tuple_str := index_tuple_str_;

                index_in_tuple := 0; // vertex_index/texture_index/normal_index
                for index_str_ in strings.split_iterator(&index_tuple_str, "/") {

                    index_str := index_str_;

                    if len(index_str) <= 0 {
                        index_in_tuple += 1;
                        continue;
                    }

                    index, index_ok := strconv.parse_u64(index_str);
                    if !index_ok {
                        fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse index '%v', on line %v.\n", index_str, current_line);
                        return;
                    }

                    switch index_in_tuple {
                        case 0: // Vertex index
                            append(&face.indices, index);
                        case 1: // Texture index
                            // Ignored
                        case 2: // Normal_Index
                            append(&face.normals, index);
                    }

                    index_in_tuple += 1;
                }

            }

            current_face += 1;

        } else if strings.has_prefix(line, "g ") {

            line = line[2:];
            group_name := strings.trim_right_space(strings.trim_left_space(line));

            result.group_names[current_group_name] = strings.clone(group_name);
            current_group_name += 1;

            faces[current_face].group = &result.groups[current_group_name];

        } else {
            result.ignored_line_count += 1;
            if warn do fmt.printf("OBJ Parse Warning: ignoring unknown/unhandled command ('%v') on line %v\n", line[:1], current_line);
        }

    }

    triangle_count := 0;
    smooth_triangle_count := 0;

    for f in faces {
        count := len(f.indices) - 2;
        if len(f.normals) == len(f.indices) {
            smooth_triangle_count += count;
        } else {
            triangle_count += count;
        }
    }

    result.triangles = make([]Triangle, triangle_count);
    result.smooth_triangles = make([]Smooth_Triangle, smooth_triangle_count);

    if face_count > 0 {
        assert(len(faces) == face_count);
        assert(current_face == face_count);

        for i in 0..<face_count {

            face := &faces[i];

            assert(len(face.indices) >= 3);

            if len(face.indices) == 3 {
                add_triangle(&result, &pc, face, 0, 1, 2);
            } else {
                for i in 2..<len(face.indices) {
                    add_triangle(&result, &pc, face, 0, i - 1, i);
                }
            }
        }
    }

    ok = true;

    return;
}

@(private="file")
add_triangle :: proc(obj: ^Parsed_Obj_File, pc: ^Obj_Parse_Context, face: ^Face, i0, i1, i2: int) {

    is_smooth := len(face.normals) == len(face.indices)

    p0 := obj.vertices[face.indices[i0] - 1];
    p1 := obj.vertices[face.indices[i1] - 1];
    p2 := obj.vertices[face.indices[i2] - 1];

    if is_smooth {

        n0 := obj.normals[face.normals[i0] - 1];
        n1 := obj.normals[face.normals[i1] - 1];
        n2 := obj.normals[face.normals[i2] - 1];

        tri := &obj.smooth_triangles[pc.current_smooth_triangle];
        tri^ = smooth_triangle(p0, p1, p2, n0, n1, n2);
        pc.current_smooth_triangle += 1;

        group_add_child(face.group, tri);

    } else {
        tri := &obj.triangles[pc.current_triangle];
        tri^ = triangle(p0, p1, p2);
        pc.current_triangle += 1;

        group_add_child(face.group, tri);
    }

}

@(private="file")
parse_point :: proc(tuple_str: string, current_line: ^int) -> (result: m.Point, success: bool) {

    success = false;

    t := parse_tuple(tuple_str, current_line) or_return;
    t.w = 1.0;

    return m.Point(t), true;
}

@(private="file")
parse_vector :: proc(tuple_str: string, current_line: ^int) -> (result: m.Vector, success: bool) {

    success = false;

    t := parse_tuple(tuple_str, current_line) or_return;
    t.w = 0.0;

    return m.Vector(t), true;
}
@(private="file")
parse_tuple :: proc(tuple_str: string, current_line: ^int) -> (result: m.Tuple, success: bool) {

    tuple_str := tuple_str;

    success = false;

    x_str, x_str_ok := strings.split_iterator(&tuple_str, " ");
    if !x_str_ok {
        fmt.fprintf(os.stderr, "OBJ Parse Error: Expected x coord after 'v' command\n");
        return;
    }

    y_str, y_str_ok := strings.split_iterator(&tuple_str, " ");
    if !y_str_ok {
        fmt.fprintf(os.stderr, "OBJ Parse Error: Expected y coord after 'v' command\n");
        return;
    }

    z_str, z_str_ok := strings.split_iterator(&tuple_str, " ");
    if !z_str_ok {
        fmt.fprintf(os.stderr, "OBJ Parse Error: Expected z coord after 'v' command\n");
        return;
    }

    w_str, w_str_ok := strings.split_iterator(&tuple_str, " ");

    x, x_ok := strconv.parse_f64(x_str);
    if !x_ok {
        fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", x_str, current_line^);
        return;
    }

    y, y_ok := strconv.parse_f64(y_str);
    if !y_ok {
        fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", y_str, current_line^);
        return;
    }

    z, z_ok := strconv.parse_f64(z_str);
    if !z_ok {
        fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", z_str, current_line^);
        return;
    }

    w : f64;
    if w_str_ok {
        w_ok : bool;
        w, w_ok = strconv.parse_f64(w_str);
        if !w_ok {
            fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", w_str, current_line^);
            return;
        }
    }

    result = m.tuple(x, y, z, w);
    success = true;

    return;
}

free_parsed_obj_file :: proc(obj: ^Parsed_Obj_File) {

    delete(obj.vertices);
    delete(obj.normals);
    delete(obj.triangles);
    delete(obj.smooth_triangles);

    for g in &obj.groups {
        delete_group(&g);
    }
    delete(obj.groups)

    for gn in obj.group_names {
        delete(gn);
    }
    delete(obj.group_names);
}

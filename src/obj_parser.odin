package raytracer

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import m "raytracer:math"

Parsed_Obj_File :: struct {
    ignored_line_count : int,

    vertices : []m.Point,
    triangles : []Triangle,

    groups : []Group,
    group_names : []string,

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
    vertex_count, face_count := 0, 0;
    group_count := 1; // Always add the root group

    // First pass, gather vertex and face count
    for _line in strings.split_lines_iterator(&obj_str) {
        line := _line;
        current_line += 1;

        line = strings.trim_left_space(line);

        if len(line) <= 1 {
            continue;
        }

        if line[:2] == "v " {
            vertex_count += 1;
        } else if line[:2] == "f " {
            face_count += 1;
        } else if line[:2] == "g " {
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

    Face :: struct {
        indices: [dynamic]u64,
        group: ^Group,
    };

    faces : []Face;

    if face_count > 0 {

        faces = make([]Face, face_count, context.temp_allocator);

        for f in &faces {
            f.indices = make([dynamic]u64, 0, 3, context.temp_allocator);
            f.group = &result.groups[0];
        }
    }

    current_line = 0;
    current_vertex := 0;
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

        if line[:2] == "v " {
            line = line[2:];
            vertex_coords := strings.trim_left_space(line);

            x_str, x_str_ok := strings.split_iterator(&vertex_coords, " ");
            if !x_str_ok {
                fmt.fprintf(os.stderr, "OBJ Parse Error: Expected x coord after 'v' command\n");
                return;
            }

            y_str, y_str_ok := strings.split_iterator(&vertex_coords, " ");
            if !y_str_ok {
                fmt.fprintf(os.stderr, "OBJ Parse Error: Expected y coord after 'v' command\n");
                return;
            }

            z_str, z_str_ok := strings.split_iterator(&vertex_coords, " ");
            if !z_str_ok {
                fmt.fprintf(os.stderr, "OBJ Parse Error: Expected z coord after 'v' command\n");
                return;
            }

            w_str, w_str_ok := strings.split_iterator(&vertex_coords, " ");

            x, x_ok := strconv.parse_f64(x_str);
            if !x_ok {
                fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", x_str, current_line);
                return;
            }

            y, y_ok := strconv.parse_f64(y_str);
            if !y_ok {
                fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", y_str, current_line);
                return;
            }

            z, z_ok := strconv.parse_f64(z_str);
            if !z_ok {
                fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", z_str, current_line);
                return;
            }

            w : f64;
            if w_str_ok {
                w_ok : bool;
                w, w_ok = strconv.parse_f64(w_str);
                if !w_ok {
                    fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse float '%v' on line %v.\n", w_str, current_line);
                    return;
                }
            }

            vertex := m.point(x, y, z);
            if w_str_ok do vertex.w = w;

            result.vertices[current_vertex] = vertex;
            current_vertex += 1;

        } else if line[:2] == "f " {

            line = line[2:];
            indices_str := strings.trim_left_space(line);

            face := &faces[current_face];

            for index_tuple_str_ in strings.split_iterator(&indices_str, " ") {

                index_tuple_str := index_tuple_str_;

                index_in_tuple := 0; // vertex_index/texture_index/normal_index
                for index_str in strings.split_iterator(&index_tuple_str, "/") {

                    if len(index_str) <= 0 do continue;

                    index, index_ok := strconv.parse_u64(index_str);
                    if !index_ok {
                        fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse index '%v', on line %v.\n", index_str, current_line);
                        return;
                    }

                    if index_in_tuple == 0 {
                        append(&face.indices, index);
                    }

                    index_in_tuple += 1;
                }

            }

            current_face += 1;

        } else if line[:2] == "g " {

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
    for f in faces {
        triangle_count += len(f.indices) - 2;
    }

    result.triangles = make([]Triangle, triangle_count);
    current_triangle := 0;

    if face_count > 0 {
        assert(len(faces) == face_count);
        assert(current_face == face_count);

        for i in 0..<face_count {

            face := faces[i];

            assert(len(face.indices) >= 3);
            if len(face.indices) == 3 {

                p0 := result.vertices[face.indices[0] - 1];
                p1 := result.vertices[face.indices[1] - 1];
                p2 := result.vertices[face.indices[2] - 1];

                tri := &result.triangles[current_triangle];
                tri^ = triangle(p0, p1, p2);
                current_triangle += 1;

                group_add_child(face.group, tri);

            } else {

                for i in 2..<len(face.indices) {

                    p0 := result.vertices[face.indices[0]     - 1];
                    p1 := result.vertices[face.indices[i - 1] - 1];
                    p2 := result.vertices[face.indices[i]     - 1];

                    tri := &result.triangles[current_triangle];
                    tri^ = triangle(p0, p1, p2);
                    current_triangle += 1;

                    group_add_child(face.group, tri);
                }
            }
        }
    }

    ok = true;

    return;
}

free_parsed_obj_file :: proc(obj: ^Parsed_Obj_File) {

    delete(obj.vertices);
    delete(obj.triangles);

    for g in &obj.groups {
        delete_group(&g);
    }
    delete(obj.groups)

    for gn in obj.group_names {
        delete(gn);
    }
    delete(obj.group_names);
}

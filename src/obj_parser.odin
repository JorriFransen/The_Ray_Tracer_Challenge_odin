package raytracer

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import m "raytracer:math"

Parsed_Obj_File :: struct {
    ignored_line_count : int,
    valid : bool,

    vertices : []m.Point,
    triangles : []Triangle,
    root_group : ^Group,
};

parse_obj_string :: proc(obj_str_: string, warn := false) -> (result: Parsed_Obj_File) {

    obj_str := obj_str_;

    current_line := 0;
    vertex_count, face_count := 0, 0;

    // First pass, gather vertex and face count
    for _line in strings.split_lines_iterator(&obj_str) {
        line := _line;
        current_line += 1;

        line = strings.trim_left_space(line);

        if len(line) <= 0 {
            continue;
        }

        if line[:2] == "v " {
            vertex_count += 1;
        } else if line[:2] == "f " {
            face_count += 1;
        }
    }

    result.vertices = make([]m.Point, vertex_count);

    Face :: struct {
        indices: [dynamic]u64,
    };

    faces : []Face;

    if face_count > 0 {

        result.root_group = new(Group);
        result.root_group^ = group();

        faces = make([]Face, face_count, context.temp_allocator);

        for f in &faces {
            f.indices = make([dynamic]u64, 0, 3, context.temp_allocator);
        }
    }

    result.valid = false;
    current_line = 0;
    current_vertex := 0;
    current_face := 0;

    // Second pass, store vertices and faces
    obj_str = obj_str_;
    for _line in strings.split_lines_iterator(&obj_str) {
        line := _line;

        current_line += 1;

        line = strings.trim_left_space(line);

        if len(line) <= 0 {
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

            for index_str in strings.split_iterator(&indices_str, " ") {

                index, index_ok := strconv.parse_u64(index_str);
                if !index_ok {
                    fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse index '%v', on line %v.\n", index_str, current_line);
                    return;
                }

                append(&face.indices, index);
            }

            current_face += 1;

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

                group_add_child(result.root_group, tri);

            } else {

                for i in 2..<len(face.indices) {

                    p0 := result.vertices[face.indices[0] - 1];
                    p1 := result.vertices[face.indices[i] - 1];
                    p2 := result.vertices[face.indices[i + 1] - 1];

                    tri := &result.triangles[current_triangle];
                    tri^ = triangle(p0, p1, p2);
                    current_triangle += 1;

                    group_add_child(result.root_group, tri);
                }
            }
        }
    }

    result.valid = true;

    return;
}

free_parsed_obj_file :: proc(obj: ^Parsed_Obj_File) {
    delete(obj.vertices);
    delete(obj.triangles);
    if obj.root_group != nil {
        delete_group(obj.root_group);
        free(obj.root_group);
    }
}

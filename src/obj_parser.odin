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
    group : ^Group,
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
        indices: [3]u64,
        extra_indices: [dynamic]u64,
    };

    faces : []Face;

    if face_count > 0 {
        result.group = new(Group);
        result.group^ = group();
        faces = make([]Face, face_count, context.temp_allocator);
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

            face : Face;
            index_count := 0;

            for index_str in strings.split_iterator(&indices_str, " ") {

                index, index_ok := strconv.parse_u64(index_str);
                if !index_ok {
                    fmt.fprintf(os.stderr, "OBJ Parse Error: Failed to parse index '%v', on line %v.\n", index_str, current_line);
                    return;
                }

                if index_count < 3 {
                    face.indices[index_count] = index;
                } else {
                    append(&face.extra_indices, index);
                }

                index_count += 1;
            }

            assert(index_count == 3 + len(face.extra_indices));

            faces[current_face] = face;
            current_face += 1;

        } else {
            result.ignored_line_count += 1;
            if warn do fmt.printf("OBJ Parse Warning: ignoring unknown/unhandled command ('%v') on line %v\n", line[:1], current_line);
        }

    }

    if face_count > 0 {
        assert(len(faces) == face_count);
        assert(current_face == face_count);

        for i in 0..<face_count {

            assert(len(faces[i].extra_indices) == 0);

            p0 := result.vertices[faces[i].indices[0] - 1];
            p1 := result.vertices[faces[i].indices[1] - 1];
            p2 := result.vertices[faces[i].indices[2] - 1];

            tri := new(Triangle);
            tri^ = triangle(p0, p1, p2);

            group_add_child(result.group, tri);
        }
    }

    result.valid = true;

    return;
}

free_parsed_obj_file :: proc(obj: ^Parsed_Obj_File) {
    delete(obj.vertices);
    if obj.group != nil {
        for c in obj.group.shapes {
            free(c);
        }

        delete_group(obj.group);
        free(obj.group);
    }
}

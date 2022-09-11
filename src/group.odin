package raytracer

import "core:slice"

import m "raytracer:math"

Group :: struct
{
    using shape: Shape,
    shapes: [dynamic]^Shape,
};

group_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Group {
    return Group { shape(_group_vtable, tf, mat), {} };
}

group_mat :: proc(mat: Material) -> Group {
    return group_tf_mat(m.matrix4_identity, mat);
}

group_tf :: proc(tf: m.Matrix4) -> Group {
    return group_tf_mat(tf, material());
}

group_default :: proc() -> Group {
    return group_tf_mat(m.matrix4_identity, material());
}

group :: proc {
    group_tf_mat,
    group_tf,
    group_mat,
    group_default,
}

delete_group :: proc(g: ^Group) {
    delete(g.shapes);
}

@(private="file")
_group_vtable := &Shape_VTable {

    normal_at = proc(s: ^Shape, p: m.Point) -> m.Vector {
        assert(false);
        return {};
    },

    intersects = group_intersects,

    eq = proc(a, b: ^Shape) -> bool { assert(false); return false },
};

group_intersects :: proc(s: ^Shape, r: m.Ray, xs_buf: ^Intersection_Buffer) -> (result: [4]Intersection, count: int) {

    group := transmute(^Group)s;

    count = 0;

    if len(group.shapes) <= 0 do return;

    xs_buf := intersection_buffer(nil);
    assert(false);

    for c in group.shapes {
        xs, child_count := intersects(c, r, &xs_buf);

        assert(count + child_count <= 4);

        if child_count > 0 {
            for i in 0..<child_count {
                result[count] = xs[i];
                count += 1;
            }
        }
    }

    slice.sort_by(result[:count], intersection_less);
    return;
}

group_add_child :: proc(group: ^Group, child: ^Shape) {

    assert(child.parent == nil);

    append(&group.shapes, child);
    child.parent = group;
}

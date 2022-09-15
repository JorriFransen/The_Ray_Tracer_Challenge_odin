package raytracer

import "core:slice"
import "core:sync"

import m "raytracer:math"

Group :: struct
{
    using shape: Shape,
    shapes: [dynamic]^Shape,
    bounds: Bounds,
};

group_tf_mat :: proc(tf: m.Matrix4, mat: Material) -> Group {
    return Group { shape(_group_vtable, tf, mat), {}, bounds() };
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

    get_bounds = get_group_bounds,

    child_count = proc(shape: ^Shape) -> int {

        group := transmute(^Group)shape;

        count := len(group.shapes);

        for o in group.shapes {
            if o.vtable.child_count != nil {
                count += o->child_count();
            }
        }

        return count;
    },

    eq = proc(a, b: ^Shape) -> bool { assert(false); return false },
};

group_intersects :: proc(s: ^Shape, r: m.Ray, xs_buf: ^Intersection_Buffer) -> []Intersection {

    group := transmute(^Group)s;

    if len(group.shapes) <= 0 do return {};

    if bounds_intersect(group.bounds, r) {

        old_count := xs_buf.count;

        for c in group.shapes {
            intersects(c, r, xs_buf);
        }

        sync.mutex_lock(&total_xs_test_mutex);
        total_xs_test += len(group.shapes);
        // total_hit += xs_buf.count - old_count;
        sync.mutex_unlock(&total_xs_test_mutex);

        slice.sort_by(xs_buf.intersections[old_count:xs_buf.count], intersection_less);
        return xs_buf.intersections[old_count:xs_buf.count];

    }

    return {};
}

get_group_bounds :: proc(shape: ^Shape) -> Bounds {

    group := transmute(^Group)shape;

    return group.bounds;
 }

group_add_child :: proc(group: ^Group, child: ^Shape) {

    assert(child.parent == nil);

    append(&group.shapes, child);
    child.parent = group;

    // Update the group bounds
    group.bounds = bounds(group.bounds, parent_space_bounds(child));
}

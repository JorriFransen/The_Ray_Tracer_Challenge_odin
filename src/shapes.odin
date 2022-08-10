package raytracer

import m "raytracer:math"

import "core:mem"

Shape :: struct {
    inverse_transform: m.Matrix4,
    material: Material,

    derived: union { ^Sphere, ^Plane, ^Test_Shape },
}


Shape_Block :: struct($T: typeid, $BLOCK_SIZE: int) {

    shapes: [BLOCK_SIZE]T,
    used: int,

    next: ^Shape_Block(T, BLOCK_SIZE),
}

Shape_Buf :: struct($T: typeid, $BLOCK_SIZE: int) {

    first_block: Shape_Block(T, BLOCK_SIZE),
    current_block: ^Shape_Block(T, BLOCK_SIZE),
}

Shapes :: struct($N: int) {

    spheres: Shape_Buf(Sphere, N),
    planes : Shape_Buf(Plane, N),

    test_shapes: Shape_Buf(Test_Shape, 4),

    allocator: mem.Allocator,
}

shapes :: proc($N: int, allocator := context.allocator) -> (result: Shapes(N)) {
    result.allocator = allocator;
    return;
}

shapes_free :: proc(s: $T/^Shapes) {

    shape_buf_free(&s.spheres, s.allocator);
    shape_buf_free(&s.test_shapes, s.allocator);
}

shape_buf_free :: proc(sb: $T/^Shape_Buf, allocator: mem.Allocator) {

    // First block is embedded so skip it
    block := sb.first_block.next;
    for block != nil {

        next := block.next;

        free(block, allocator);

        block = next;
    }

    sb^ = ---;
}

shape_tf_mat :: proc(shapes: $S/^Shapes sb: ^Shape_Buf($T, $BS), tf: m.Matrix4, mat: Material) -> ^T {


    if sb.current_block == nil do sb.current_block = &sb.first_block;

    if sb.current_block.used >= BS {
        assert(shapes.allocator.procedure != nil); // Should be set when expecting growing behaviour
        new_block := new(Shape_Block(T, BS), shapes.allocator);
        sb.current_block.next = new_block;
        sb.current_block = new_block;
    }

    r := &sb.current_block.shapes[sb.current_block.used];
    sb.current_block.used += 1;

    r.derived = r;
    set_transform(r, tf);
    set_material(r, mat);

    return r;
}

shape_mat :: proc(shapes: $S/^Shapes, sb: ^Shape_Buf($T, $BS), mat: Material) -> ^T {
    return shape_tf_mat(shapes, sb, m.matrix4_identity, mat);
}

shape_tf :: proc(shapes: $S/^Shapes, sb: ^Shape_Buf($T, $BS), tf: m.Matrix4) -> ^T {
    return shape_tf_mat(shapes, sb, tf, default_material);
}

shape_default :: proc(shapes: $S/^Shapes, sb: ^Shape_Buf($T, $BS)) -> ^T {
    return shape_tf_mat(shapes, sb, m.matrix4_identity, material());
}

shape :: proc {
    shape_tf_mat,
    shape_mat,
    shape_tf,
    shape_default,
}

shape_eq :: proc(a, b: Shape) -> bool {

    if type_of(a.derived) != type_of(b.derived) do return false;
    if a.material != b.material do return false;
    if !eq(a.inverse_transform, b.inverse_transform) do return false;

    switch k in a.derived {
        case ^Sphere: return true;
        case ^Plane: assert(false);
        case ^Test_Shape: assert(false);
    }

    assert(false);
    return false;
}

set_transform :: proc(s: ^Shape, new_tf: m.Matrix4) {
    s.inverse_transform = m.matrix_inverse(new_tf);
}

set_material :: proc(s: ^Shape, mat: Material) {
    s.material = mat;
}

normal_at :: proc(s: ^Shape, p: m.Point) -> m.Vector {

    obj_p := s.inverse_transform * p;
    obj_n : m.Vector;

    switch k in s.derived {
        case ^Sphere: obj_n = sphere_normal_at(k, obj_p);
        case ^Plane: obj_n = plane_normal_at(k, obj_p);
        case ^Test_Shape: obj_n = test_shape_normal_at(k, obj_p);
    }

    world_n := m.matrix4_transpose(s.inverse_transform) * obj_n;
    world_n.w = 0;

    return m.normalize(world_n);
}

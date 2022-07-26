package main

import "core:fmt"
import i "core:intrinsics"
import m "rtmath"

main :: proc() {

    T :: m.Tuple(f32);
    P :: m.Point(f32);
    V :: m.Vector(f32);

    fmt.println("typeid_of(T):", typeid_of(T));
    fmt.println("typeid_of(P):", typeid_of(P));
    fmt.println("typeid_of(V):", typeid_of(V));
    fmt.println("");
    fmt.println("type_is_specialization_of(T, Tuple)", i.type_is_specialization_of(T, m.Tuple));
    fmt.println("type_is_specialization_of(P, Tuple)", i.type_is_specialization_of(P, m.Tuple));
    fmt.println("type_is_specialization_of(V, Tuple)", i.type_is_specialization_of(V, m.Tuple));
    fmt.println("");
    fmt.println("type_base_type(T):", typeid_of(i.type_base_type(T)));
    fmt.println("type_base_type(P):", typeid_of(i.type_base_type(P)));
    fmt.println("type_base_type(V):", typeid_of(i.type_base_type(V)));
    fmt.println("");
    fmt.println("type_core_type(T):", typeid_of(i.type_core_type(T)));
    fmt.println("type_core_type(P):", typeid_of(i.type_core_type(P)));
    fmt.println("type_core_type(V):", typeid_of(i.type_core_type(V)));
    fmt.println("");
    fmt.println("type_is_specialized_polymorphic_record(T):", i.type_is_specialized_polymorphic_record(T));
    fmt.println("type_is_specialized_polymorphic_record(P):", i.type_is_specialized_polymorphic_record(V));
    fmt.println("type_is_specialized_polymorphic_record(V):", i.type_is_specialized_polymorphic_record(P));
    fmt.println("");
    fmt.println("type_is_subtype_of(T, Tuple)", i.type_is_subtype_of(T, m.Tuple));
    fmt.println("type_is_subtype_of(P, Tuple(f32))", i.type_is_subtype_of(P, m.Tuple(f32)));
    fmt.println("type_is_subtype_of(V, Tuple)", i.type_is_subtype_of(V, m.Tuple));

    fmt.println("type_polymorphic_record_parameter_count(P):", i.type_polymorphic_record_parameter_count(P));
    fmt.println("type_polymorphic_record_parameter_value(P, 0):", typeid_of(i.type_polymorphic_record_parameter_value(P, 0)));

    /*fmt.println("is_tuple(T):", m.is_tuple(T));*/
    /*fmt.println("is_tuple(P):", m.is_tuple(P));*/
    /*fmt.println("is_tuple(V):", m.is_tuple(V));*/

    t1 := m.tuple(f32, 1.000001, 2, 3, 4 );
    t2 := m.tuple(f32, 1, 2, 3, 4 );

    eq_old :: proc(a, b: $T) -> bool {
        return m.float_eq(a.x, b.x) && m.float_eq(a.y, b.y) && m.float_eq(a.z, b.z) && m.float_eq(a.w, b.w);
    }

    fmt.println("eq(t1, t2):", m.eq(t1, t2));
    fmt.println("eq_old(t1, t2):", eq_old(t1, t2));
    /*fmt.println("t1 + t2:", t1.data + t2.data);*/

    /*a := transmute(#simd[4]f32)t1;*/
    /*b : #simd[4]f32 = { 1, 2, 3, 4 }*/
    /*c := a + b;*/
    /*fmt.println("a + b:", c);*/
    /*fmt.println("a + b:", i.simd_add(a, b));*/

}


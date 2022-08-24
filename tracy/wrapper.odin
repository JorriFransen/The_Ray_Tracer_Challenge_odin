package tracy



Zone__ :: #force_inline proc(loc := #caller_location) -> (ctx: Tracy_Zone_Context) {
    when ENABLED {
        id := ___tracy_alloc_srcloc(u32(loc.line),
                                    cstring(raw_data(loc.file_path)),
                                    len(loc.file_path),
                                    cstring(raw_data(loc.procedure)),
                                    len(loc.procedure));

        ctx = ___tracy_emit_zone_begin_alloc_callstack(id, 99, 1);
    }

    return;
}

@(deferred_out=ZoneEnd)
Zone_ :: #force_inline proc(loc := #caller_location) -> (ctx: Tracy_Zone_Context) {
    when ENABLED {
        ctx = Zone__(loc);
    }

    return;
}

@(deferred_out=ZoneEnd)
ZoneN :: #force_inline proc(name: string,loc := #caller_location) -> (ctx: Tracy_Zone_Context) {
    when ENABLED {
        ctx = Zone__(loc);
        ___tracy_emit_zone_name(ctx, cstring(raw_data(name)), len(name));
    }

    return;
}

Zone :: proc {
    Zone_,
    ZoneN,
}

ZoneEnd :: #force_inline proc(ctx: Tracy_Zone_Context) {
    when ENABLED {
        ___tracy_emit_zone_end(ctx);
    }
}

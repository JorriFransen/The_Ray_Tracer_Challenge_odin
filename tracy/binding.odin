package tracy

import "core:c"
import "core:os"

when os.OS == .Linux do foreign import tracy "tracy/tracy.so"

ENABLED :: #config(TRACY_ENABLE, false)

Tracy_Zone_Context :: struct {
    id    : u32,
    active: c.int,
}

@(default_calling_convention="c")
foreign tracy {
    ___tracy_alloc_srcloc :: proc(line: u32, source: cstring, sourceSz: c.size_t, function: cstring, functionSz: c.size_t) -> u64 ---;
    ___tracy_emit_zone_begin_alloc :: proc(srcloc: u64, active: c.int) -> Tracy_Zone_Context ---;
    ___tracy_emit_zone_begin_alloc_callstack :: proc(srcloc: u64, depth: c.int, active: c.int) -> Tracy_Zone_Context ---;

    ___tracy_emit_zone_name :: proc(ctx: Tracy_Zone_Context, text: cstring, size: c.size_t) ---;
    ___tracy_emit_zone_end :: proc(ctx: Tracy_Zone_Context) ---;

}


package tests

import "core:fmt"
import "core:os"
import "core:mem"

import r "runner"

import math_tests "math"
import graphics_tests "graphics"
import world_tests "world"

main_suite := r.Test_Suite {
    name = "",
    tests = {},
    child_suites = {
        &math_tests.math_suite,
        &graphics_tests.graphics_suite,
        &world_tests.world_suite,
    },
}

main :: proc() {

    track : mem.Tracking_Allocator;
    mem.tracking_allocator_init(&track, context.allocator);
    context.allocator = mem.tracking_allocator(&track);

    options, options_ok := parse_options(os.args[1:]);
    if !options_ok do return;

    if !r.execute_test_suite(&main_suite, options) {
        os.exit(1);
    }

    for _, leak in track.allocation_map {
        fmt.printf("%v leaked %v bytes\n", leak.location, leak.size);
    }

    for bad_free in track.bad_free_array {
        fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory);
    }
}

parse_options :: proc(args: []string) -> (result: r.Test_Options, ok: bool) {
    result = r.default_test_options();
    ok = true;

    for arg in args {
        switch arg {
            case "-no-color": {
                result.print_color = false;
            }
            case: {
                fmt.eprintf("Invalid option: '%s'\n", arg);
                usage();
                ok = false;
                return;
            }
        }
    }
    return;
}

usage :: proc() {
    fmt.printf("usage: %s [options]\n", os.args[0]);
    fmt.printf("Options:\n");
    fmt.printf("  -no-color    Disable colored (ansi) ouput.\n")
    fmt.printf("\n");
}

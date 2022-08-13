package tests

import "core:fmt"
import "core:os"
import "core:mem"

import rt "raytracer:."
import r "raytracer:test_runner"

import math_tests "math"
import graphics_tests "graphics"
import world_tests "world"

expect :: r.expect;
eq :: rt.eq;

main_suite := r.Test_Suite {
    name = "",
    tests = {},
    child_suites = {
        &math_tests.math_suite,
        &graphics_tests.graphics_suite,
        &world_tests.world_suite,
        &pattern_suite,
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

    parsed_arg_count := 0;
    prefix_set := false;

loop:
    for arg in args {

        if prefix_set do break;

        switch arg {

            case "-no-color":
                result.print_color = false;

            case:
                if arg[0] == '-' do break loop;
                if prefix_set do break loop;
                fmt.printf("Prefix: '%s'\n", arg);
                result.test_prefix = arg;
                prefix_set = true;
                break;
        }

        parsed_arg_count += 1;
    }

    if parsed_arg_count < len(args) {
        fmt.eprintf("Invalid option: '%s'\n", args[parsed_arg_count]);
        usage();
        ok = false;
    }

    return;
}

usage :: proc() {
    fmt.printf("usage: %s [options] [prefix]\n", os.args[0]);
    fmt.printf("Options:\n");
    fmt.printf("  -no-color    Disable colored (ansi) ouput.\n")
    fmt.printf("\n")
    fmt.printf("Prefix:        Only run tetst with this prefix.");
    fmt.printf("\n");
}

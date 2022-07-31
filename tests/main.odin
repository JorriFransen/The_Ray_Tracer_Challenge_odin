package tests

import "core:fmt"
import "core:os"

main :: proc() {

    options, ok := parse_options(os.args[1:]);
    if !ok do return;

    execute_test_suite(math_suite, options);
}

parse_options :: proc(args: []string) -> (result: Test_Options, ok: bool) {
    result = default_test_options();
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

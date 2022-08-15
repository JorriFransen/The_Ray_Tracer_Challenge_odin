package tests_runner

import "core:c/libc"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"

Test_Signature :: proc(^Test_Context);

Setup_Test_Signature :: proc(^Test_Context);
Teardown_Test_Signature :: proc(^Test_Context);

Test :: struct {
    name: string,

    t: Test_Signature,
    setup: Setup_Test_Signature,
    teardown: Teardown_Test_Signature,
}

Test_Suite :: struct {
    name: string,
    tests: []Test,

    child_suites: []^Test_Suite,

    setup: Setup_Test_Signature `Runs before each test`,
    teardown: Teardown_Test_Signature `Runs after each test`,
}

Test_Context :: struct {
    main_suite: ^Test_Suite,

    total_test_count, test_fail_count, assert_fail_count: int,

    test_sb: strings.Builder,

    print_color: bool,
    test_prefix: string,
}

Test_Options :: struct {
    print_color: bool,
    test_prefix: string,
}

test :: proc (name: string, test_fn: Test_Signature, setup_fn: Setup_Test_Signature = nil, teardown_fn: Setup_Test_Signature = nil) -> Test {
    return Test {  name, test_fn, setup_fn, teardown_fn };
}


default_test_options :: proc() -> Test_Options {
    return Test_Options {
        print_color = true,
    };
}

test_context :: proc(s: ^Test_Suite, options: Test_Options) -> Test_Context {

    return Test_Context {
        main_suite = s,
        total_test_count = 0,
        test_fail_count = 0,
        assert_fail_count = 0,
        test_sb = strings.builder_make(),
        print_color = options.print_color,
        test_prefix = options.test_prefix,
    };
}

test_context_free :: proc(tc: ^Test_Context) {
    strings.builder_destroy(&tc.test_sb);
}

execute_test_suite_s :: proc(s: ^Test_Suite, options: Test_Options) -> bool {

    c := test_context(s, options);
    defer test_context_free(&c);
    ok := execute_test_suite(&c, s);

    success_count := c.total_test_count - c.test_fail_count;
    percentage := f32(success_count) / f32(c.total_test_count) * 100;
    precision := 0 if ok else 2;
    report_color : Print_Color = .Green if ok else .Red;

    report_msg := fmt.aprintf("{:d} of {:d} ({:.*f}%%) tests succesful\n", success_count, c.total_test_count, precision, percentage);
    defer delete(report_msg);

    print_color(&c, os.stdout, report_msg, report_color);

    return ok;
}

execute_test_suite_csp :: proc(c: ^Test_Context, s: ^Test_Suite, prefix: string = "") -> bool {

    current_prefix := strings.concatenate({prefix, s.name});
    defer delete(current_prefix);

    if len(current_prefix) > 0 {
        min_len := min(len(current_prefix), len(c.test_prefix));

        if current_prefix[:min_len] != c.test_prefix[:min_len] {
            return true;
        }
    }

    tests_ok := true;

    for t in &s.tests {


        if s.setup != nil do s.setup(c);

        if !execute_test(c, &t, current_prefix) do tests_ok = false;

        if s.teardown != nil do s.teardown(c);
    }

    suites_ok := true;

    for child in s.child_suites {
        if !execute_test_suite(c, child, current_prefix) do suites_ok = false;
    }

    return tests_ok && suites_ok;
}

execute_test_suite :: proc {
    execute_test_suite_s,
    execute_test_suite_csp,
}

execute_test :: proc(c: ^Test_Context, test: ^Test, prefix: string = "") -> bool {

    current_prefix := strings.concatenate({prefix, test.name});
    defer delete(current_prefix);

    if len(current_prefix) > 0 {
        min_len := min(len(current_prefix), len(c.test_prefix));

        if current_prefix[:min_len] != c.test_prefix[:min_len] {
            return true;
        }
    }

    strings.builder_reset(&c.test_sb);

    old_fail_count := c.assert_fail_count;

    c.total_test_count += 1;

    if test.setup != nil do test.setup(c);

    test.t(c);

    if test.teardown != nil do test.teardown(c);

    test_ok := old_fail_count == c.assert_fail_count;


    status: string;
    color: Print_Color;
    if test_ok {
        status = "OK  ";
        color = .Green;
    } else {
        status = "FAIL";
        color = .Red;
    }

    print_color(c, os.stdout, status, color);
    fmt.printf(" %s%s\t\n", prefix, test.name);

    if !test_ok {
        c.test_fail_count += 1;
        fmt.println(strings.to_string(c.test_sb));
    }

    return test_ok;
}

expect :: proc(tc: ^Test_Context, condition: bool, message: string = "", loc := #caller_location) {

    if !condition {
        tc.assert_fail_count += 1;

        maybe_colon := ": " if len(message) > 0 else "";
        loc_str := fmt.tprintf("[%v] assert fail%v", loc, maybe_colon);

        writer := strings.to_writer(&tc.test_sb);

        print_color(tc, writer, loc_str, .Red);
        fmt.sbprintf(&tc.test_sb, "%v\n", message);
        return
    }
}

log :: proc(tc: ^Test_Context, v: any, loc := #caller_location) {

    msg := fmt.tprintf("[%v] log: ", loc)

    writer := strings.to_writer(&tc.test_sb);

    print_color(tc, writer, msg, .Yellow);
    fmt.sbprintf(&tc.test_sb, "%v\n", v)
}

@private
Print_Color :: enum rune {
    Red = '1',
    Green = '2',
    Yellow = '3',
    Blue = '4',
}

@private
print_color_h :: proc(c: ^Test_Context, fd: os.Handle, s: string, col: Print_Color) {

    assert(fd >= 1);

    stream := os.stream_from_handle(fd);
    writer, ok := io.to_writer(stream);
    assert(ok);

    print_color_w(c, writer, s, col);
}

@private
print_color_w :: proc(c: ^Test_Context, w: io.Writer, s: string, col: Print_Color) {

    if c.print_color {
        fmt.wprintf(w, "\x1b[3%cm%s\x1b[39m", rune(col), s);
        return;
    }

    fmt.wprintf(w, "%s", s);
}

@private
print_color :: proc {
    print_color_h,
    print_color_w,
}

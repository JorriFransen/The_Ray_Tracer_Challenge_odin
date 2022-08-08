package tests_runner

import "core:fmt"
import "core:os"
import "core:strings"
import "core:c/libc"
import "core:io"

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

    test_writer: io.Writer,
    stdout_writer: io.Writer,

    print_color: bool,
}

Test_Options :: struct {
    print_color: bool,
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
        test_writer = {},
        stdout_writer = io.to_writer(os.stream_from_handle(os.stdout)),
        print_color = options.print_color,
    };
}

execute_test_suite_s :: proc(s: ^Test_Suite, options: Test_Options) -> bool {

    c := test_context(s, options);
    ok := execute_test_suite(&c, s);

    success_count := c.total_test_count - c.test_fail_count;
    percentage := f32(success_count) / f32(c.total_test_count) * 100;
    precision := 0 if ok else 2;
    report_color : Print_Color = .Green if ok else .Red;

    report_msg := fmt.aprintf("{:d} of {:d} ({:.*f}%%) tests succesful\n", success_count, c.total_test_count, precision, percentage);
    defer delete(report_msg);

    print_color(&c, c.stdout_writer, report_msg, report_color);

    return ok;
}

execute_test_suite_csp :: proc(c: ^Test_Context, s: ^Test_Suite, prefix: string = "") -> bool {

    c.total_test_count += len(s.tests);

    current_prefix := strings.concatenate({prefix, s.name});
    defer delete(current_prefix);

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

    fd := tmpfile();
    defer os.close(fd);

    tmpstream := os.stream_from_handle(fd);
    w := io.to_writer(tmpstream);


    c.test_writer = w;
    old_fail_count := c.assert_fail_count;


    if test.setup != nil do test.setup(c);

    test.t(c);

    if test.teardown != nil do test.teardown(c);

    test_ok := old_fail_count == c.assert_fail_count;
    c.test_writer = {};


    status: string;
    color: Print_Color;
    if test_ok {
        status = "OK  ";
        color = .Green;
    } else {
        status = "FAIL";
        color = .Red;
    }

    print_color(c, c.stdout_writer, status, color);
    fmt.printf(" %s%s\t", prefix, test.name);
    fmt.println();

    if !test_ok {
        c.test_fail_count += 1;
        os.seek(fd, 0, os.SEEK_SET);
        buf, ok := os.read_entire_file_from_handle(fd);
        defer delete(buf);
        assert(ok);
        fmt.println(string(buf));
    }

    return test_ok;
}

expect :: proc(tc: ^Test_Context, condition: bool, message: string = "", loc := #caller_location) {

    if !condition {
        tc.assert_fail_count += 1;

        maybe_colon := ": " if len(message) > 0 else "";
        loc_str := fmt.tprintf("[%v] assert fail%v", loc, maybe_colon);

        print_color(tc, tc.test_writer, loc_str, .Red);
        fmt.wprintf(tc.test_writer, "%v\n", message);
        return
    }
}

log :: proc(tc: ^Test_Context, v: any, loc := #caller_location) {

    msg := fmt.tprintf("[%v] log: ", loc)
    print_color(tc, tc.test_writer, msg, .Yellow);
    fmt.wprintf(tc.test_writer, "%v\n", v)
}

@private
Print_Color :: enum rune {
    Red = '1',
    Green = '2',
    Yellow = '3',
    Blue = '4',
}

@private
print_color :: proc(c: ^Test_Context, w: io.Writer, s: string, col: Print_Color) {
    if c.print_color {
        fmt.wprintf(w, "\x1b[3%cm%s\x1b[39m", rune(col), s);
        return;
    }

    fmt.wprintf(w, "%s", s);
}

@private
tmpfile :: proc() -> os.Handle {
    cfile : ^libc.FILE = libc.tmpfile();
    assert(cfile != nil);
    return to_handle(cfile);

}

when ODIN_OS == .Linux {
    foreign import _libc "system:c"

    @(private="file")
    @(default_calling_convention="c")
    foreign _libc {

        fileno :: proc(stream: ^libc.FILE) -> int ---;
    }

    @private
    to_handle :: proc(cfile: ^libc.FILE) -> os.Handle {
        return os.Handle(fileno(cfile));
    }

} else when ODIN_OS == .Windows {
    foreign import _libc "system:libucrt.lib";
    import widows "core:sys/windows";

    @(private="file")
    @(default_calling_convention="c")
    foreign _libc {
        _fileno :: proc(stream: ^libc.FILE) -> int ---;
        _get_osfhandle :: proc(fd: int) -> widows.HANDLE ---;
    }

    @private
    to_handle :: proc(cfile: ^libc.FILE) -> os.Handle {
        return os.Handle(_get_osfhandle(_fileno(cfile)));
    }
} else {
    #assert(false, "OS not supported");
}

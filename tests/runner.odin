package tests

import "core:fmt"
import "core:os"
import "core:testing"
import "core:strings"
import "core:c/libc"
import "core:io"

TEST_count := 0;
TEST_fail := 0;

Test :: struct {
    using internal: testing.Internal_Test,
}

Test_Suite :: struct {
    name: string,
    tests: []Test,
}

Test_Context :: struct {
    using t : testing.T,

    main_suite: ^Test_Suite,

    total_test_count, test_fail_count, assert_fail_count: int,

    test_writer : io.Writer,
    stdout_writer: io.Writer,
}

execute_test_suite_s :: proc(s: ^Test_Suite) {
    c := Test_Context { {}, s, 0, 0, 0, {}, io.to_writer(os.stream_from_handle(os.stdout)) };
    execute_test_suite(&c, s);

    success_count := c.total_test_count - c.test_fail_count;
    percentage := f32(success_count) / f32(c.total_test_count) * 100;
    precision := 2 if c.test_fail_count != 0 else 0;
    fmt.printf("{:d} of {:d} ({:.*f}%%) tests succesful\n", success_count, c.total_test_count, precision, percentage);
}

execute_test_suite_csp :: proc(c: ^Test_Context, s: ^Test_Suite, prefix: string = "") {

    c.total_test_count += len(s.tests);

    current_prefix := strings.concatenate({prefix, s.name}, context.temp_allocator);

    for _,i in s.tests {
        execute_test(c, &s.tests[i], current_prefix);
    }
}

execute_test_suite :: proc {
    execute_test_suite_s,
    execute_test_suite_csp,
}

execute_test :: proc(c: ^Test_Context, test: ^Test, prefix: string = "") {

    fd := tmpfile();
    defer os.close(fd);

    tmpstream := os.stream_from_handle(fd);
    w := io.to_writer(tmpstream);


    c.test_writer = w;
    old_fail_count := c.assert_fail_count;

    test.p(c);

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

    print_color(c.stdout_writer, status, color);
    fmt.printf(" %s%s\t", prefix, test.name);
    fmt.println();

    if !test_ok {
        c.test_fail_count += 1;
        os.seek(fd, 0, os.SEEK_SET);
        buf, ok := os.read_entire_file_from_handle(fd, context.temp_allocator);
        assert(ok);
        fmt.print(string(buf));
    }
}

when ODIN_TEST {
    expect  :: testing.expect
    log     :: testing.log
} else {
    expect :: proc(t: ^testing.T, condition: bool, message: string = "", loc := #caller_location) {

        c := transmute(^Test_Context)t;

        TEST_count += 1
        if !condition {
            TEST_fail += 1
            c.assert_fail_count += 1;
            loc_str := fmt.tprintf("[%v] ", loc);
            print_color(c.test_writer, loc_str, .Red);
            fmt.wprintf(c.test_writer, "%v\n", message);
            return
        }
    }
    log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
        c := transmute(^Test_Context)t;
        msg := fmt.tprintf("[%v] log: ", loc)
        print_color(c.test_writer, msg, .Yellow);
        fmt.wprintf(c.test_writer, "%v\n", v)
    }
}

@private
Print_Color :: enum rune {
    Red = '1',
    Green = '2',
    Yellow = '3',
    Blue = '4',
}

@private
_MyFile :: struct {
    _padding0: int,
    _padding1: [13]uintptr,
    fileno: int,
}

print_color :: proc(w: io.Writer, s: string, c: Print_Color) {
    fmt.wprintf(w, "\x1b[3%cm%s\x1b[39m", rune(c), s);
}

@private
to_handle :: proc(cfile: ^libc.FILE) -> os.Handle {
    when ODIN_OS == .Linux {
        mfile := transmute(^_MyFile)cfile;
        return os.Handle(mfile.fileno);
    } else when ODIN_OS == .Windows {
        assert(false);
    }
}

@private
tmpfile :: proc() -> os.Handle {
    cfile : ^libc.FILE = libc.tmpfile();
    assert(cfile != nil);
    return to_handle(cfile);

}

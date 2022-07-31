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

    current_writer : io.Writer,
}

execute_test_suite_s :: proc(s: ^Test_Suite) {
    c := Test_Context { {}, s, 0, 0, 0, {} };
    execute_test_suite(&c, s);

    success_count := c.total_test_count - c.test_fail_count;
    percentage := f32(success_count) / f32(c.total_test_count) * 100;
    fmt.printf("{0:d} of {1:d} ({2:.2f}%%) tests succesful\n", success_count, c.total_test_count, percentage);
}

execute_test_suite_csp :: proc(c: ^Test_Context, s: ^Test_Suite, prefix: string = "") {

    c.total_test_count += len(s.tests);

    current_prefix := prefix;
    modified_prefix := false;

    if len(s.name) > 0 {
        current_prefix = strings.concatenate({ prefix, s.name });
        modified_prefix = true;
    }

    for _,i in s.tests {
        execute_test(c, &s.tests[i], current_prefix);
    }

    if modified_prefix do delete(current_prefix);
}

execute_test_suite :: proc {
    execute_test_suite_s,
    execute_test_suite_csp,
}

execute_test :: proc(c: ^Test_Context, test: ^Test, prefix: string = "") {
    fmt.printf("%s%s\t", prefix, test.name);


    fd := tmpfile();
    defer os.close(fd);

    tmpstream := os.stream_from_handle(fd);
    w := io.to_writer(tmpstream);


    c.current_writer = w;
    old_fail_count := c.assert_fail_count;

    test.p(c);

    test_ok := old_fail_count == c.assert_fail_count;
    c.current_writer = {};


    status := "OK" if test_ok else "FAIL";
    fmt.println(status);

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
            fmt.wprintf(c.current_writer, "[%v] %v\n", loc, message)
            return
        }
    }
    log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
        c := transmute(^Test_Context)t;
        fmt.wprintf(c.current_writer, "[%v] ", loc)
        fmt.wprintf(c.current_writer, "log: %v\n", v)
    }
}

@private
_MyFile :: struct {
    _padding0: int,
    _padding1: [13]uintptr,
    fileno: int,
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

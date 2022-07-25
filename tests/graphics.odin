package tests;

import "core:fmt"
import "core:testing"

import g "../src/graphics"

all_graphics_tests :: proc(t: ^testing.T) {
    test_graphics_test(t);
}

@test
test_graphics_test :: proc(t: ^testing.T) {
    when !ODIN_TEST { fmt.println(#procedure); }

}

package tests;

graphics_suite := Test_Suite {
    name = "GFX/",
    tests = { },
    child_suites = {
        &color_suite,
        &canvas_suite,
    },
}

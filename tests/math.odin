package tests

math_suite := Test_Suite {
    name = "Math/",
    tests = { },
    child_suites = {
        &vec_suite,
        &matrix_suite,
        &transform_suite,
        &ray_suite,
        &shape_suite,
    },
}


package tests

math_suite := Test_Suite {
    name = "Math/",
    tests = { },
    child_suites = {
        &vec_suite,
        &matrix_suite,
    },
}


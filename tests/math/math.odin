package tests_math

import t "../runner"

math_suite := t.Test_Suite {
    name = "Math/",
    tests = { },
    child_suites = {
        &vec_suite,
        &matrix_suite,
        &transform_suite,
        &ray_suite,
    },
}


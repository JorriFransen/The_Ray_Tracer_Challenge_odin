
package tests

import "core:fmt"
import "core:os"
import "core:testing"

TEST_count := 0;
TEST_fail := 0;

main :: proc() {

    t := testing.T{};

    Tuple_Is_Point(&t);
    Tuple_Is_Vector(&t);
    Point_Constructor(&t);
    Vector_Constructor(&t);

    Tuple_Add(&t);
    Add_Point_And_Vector(&t);
    Add_Vector_And_Point(&t);
    Vector_Add(&t);

    Tuple_Sub(&t);
    Point_Sub(&t);
    Point_Sub_Vector(&t);
    Vector_Sub(&t);

    Vector_Sub_From_Zero(&t);
    Tuple_Negate(&t);
    Vector_Negate(&t);

    Tuple_Mul_Scalar(&t);
    Tuple_Mul_Fraction(&t);

    Tuple_Div_Scalar(&t);

    Vector_Magnitude_X1(&t);
    Vector_Magnitude_Y1(&t);
    Vector_Magnitude_Z1(&t);
    Vector_Magnitude_X1_Y2_Z3(&t);
    Vector_Magnitude_X1_Y2_Z3_Neg(&t);

    Vector_Normalize_X4(&t);
    Vector_Normalize_X1_Y2_Z3(&t);

    Vector_Dot(&t);
    Vector_Cross(&t);

    fmt.printf("%v/%v tests successful.\n", TEST_count - TEST_fail, TEST_count)
    if TEST_fail > 0 {
        os.exit(1)
    }
}

when ODIN_TEST {
    expect  :: testing.expect
    log     :: testing.log
} else {
    expect  :: proc(t: ^testing.T, condition: bool, message: string = "", loc := #caller_location) {
        TEST_count += 1
        if !condition {
            TEST_fail += 1
            fmt.printf("[%v] %v\n", loc, message)
            return
        }
    }
    log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
        fmt.printf("[%v] ", loc)
        fmt.printf("log: %v\n", v)
    }
}
